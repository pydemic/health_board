defmodule HealthBoard.Updaters.FluSyndromeUpdater do
  use GenServer, restart: :permanent
  require Logger
  alias HealthBoard.Contexts.Dashboards
  alias HealthBoard.Updaters.{FluSyndromeUpdater, Helpers, Reseeder}

  @args_keys [
    :reattempt_initial_milliseconds,
    :path,
    :update_at_hour,
    :source_id,
    :source_sid,
    :consolidator_opts,
    :header_api_opts
  ]

  @type t :: %FluSyndromeUpdater{
          status: atom,
          statuses: list(atom),
          error?: boolean,
          attempts: integer,
          reattempt_after_milliseconds: integer,
          reattempt_initial_milliseconds: integer,
          last_error: any,
          last_stacktrace: Exception.stacktrace(),
          path: String.t(),
          update_at_hour: integer,
          source_sid: String.t(),
          source_id: integer,
          header: map | nil,
          last_header: map | nil,
          consolidator_opts: keyword,
          header_api_opts: keyword
        }

  defstruct status: :new,
            statuses: [
              :fetch_header,
              :download_data,
              :consolidate_data,
              :seed_data,
              :update_source,
              :backup_data
            ],
            error?: false,
            attempts: 0,
            reattempt_after_milliseconds: 0,
            reattempt_initial_milliseconds: 60_000,
            last_error: nil,
            last_stacktrace: nil,
            path: Path.join(File.cwd!(), ".misc/sandbox/updates/flu_syndrome"),
            update_at_hour: 3,
            source_sid: "e_sus_sg",
            source_id: nil,
            header: nil,
            last_header: nil,
            consolidator_opts: [],
            header_api_opts: []

  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    GenServer.start(FluSyndromeUpdater, args, name: FluSyndromeUpdater)
  end

  @impl GenServer
  @spec init(keyword) :: {:ok, t()}
  def init(args) do
    FluSyndromeUpdater.Consolidator.init()

    {:ok,
     args
     |> new()
     |> Helpers.schedule(3_000)}
  end

  @impl GenServer
  @spec handle_info(atom, t()) :: {:noreply, t()}
  def handle_info(:update, state) do
    {:noreply, Helpers.handle_state(state)}
  end

  @spec new(keyword | map) :: t()
  def new(fields) when is_list(fields), do: struct(FluSyndromeUpdater, Keyword.take(fields, @args_keys))
  def new(fields) when is_map(fields), do: struct(FluSyndromeUpdater, Map.take(fields, @args_keys))

  @spec reset(t()) :: t()
  def reset(state) do
    if state.status == :seed_data do
      rollback_data(state)
    end

    new(state)
  end

  defp rollback_data(state) do
    case Reseeder.reseed(backup_path(state)) do
      :ok -> Logger.info("Data rolled back")
      _error -> Logger.error("Failed to rollback data")
    end
  end

  @spec schedule(t()) :: t()
  def schedule(state) do
    Helpers.schedule_at_hour(state, state.update_at_hour)
  end

  # Steps

  @spec fetch_header(t()) :: t()
  def fetch_header(%{header_api_opts: opts, header: current_header} = state) do
    Logger.info("Fetching header")

    case FluSyndromeUpdater.HeaderAPI.get(opts) do
      {:ok, header} -> struct(state, header: header, last_header: current_header)
      {:error, error} -> Helpers.handle_error(state, "Failed to fetch header", error)
    end
  end

  @spec download_data(t()) :: t()
  def download_data(%{header: %{urls: urls} = header, last_header: last_header} = state) do
    Logger.info("Downloading data")

    {source, state} = fetch_source(state)

    if download_data?(header, last_header, source) do
      input_path = input_path(state)

      File.rm_rf!(input_path)
      File.mkdir_p!(input_path)

      Enum.each(urls, &download_csv(&1, input_path))

      struct(state, last_header: header)
    else
      Logger.info("Database is updated")
      struct(state, status: :idle)
    end
  rescue
    error -> Helpers.handle_error(state, "Failed to download data", error, __STACKTRACE__)
  catch
    error -> Helpers.handle_error(state, "Failed to download data", error)
  end

  defp fetch_source(%{source_id: id, source_sid: sid} = state) do
    if is_nil(id) do
      case Dashboards.Sources.fetch_by_sid(sid) do
        {:ok, %{id: id} = source} -> {source, struct(state, source_id: id)}
        :error -> {nil, state}
      end
    else
      case Dashboards.Sources.fetch(id) do
        {:ok, source} -> {source, state}
        :error -> {nil, struct(state, source_id: nil)}
      end
    end
  end

  defp download_data?(%{updated_at: updated_at}, last_header, source) do
    if is_nil(last_header) do
      case source do
        %{last_update_date: %Date{} = date} -> Date.compare(NaiveDateTime.to_date(updated_at), date) == :gt
        _source -> true
      end
    else
      NaiveDateTime.compare(updated_at, last_header.updated_at) == :gt
    end
  end

  defp download_csv(url, input_path) do
    csv_path = Path.join(input_path, Path.basename(url))

    case :httpc.request(:get, {String.to_charlist(url), []}, [], stream: String.to_charlist(csv_path)) do
      {:ok, _result} -> :ok
      {:error, error} -> throw(error)
    end
  end

  @spec consolidate_data(t()) :: t()
  def consolidate_data(%{consolidator_opts: opts} = state) do
    Logger.info("Consolidating data")

    output_path = output_path(state)

    File.rm_rf!(output_path)
    File.mkdir_p!(output_path)

    FluSyndromeUpdater.ConsolidatorManager.consolidate(
      Keyword.merge(opts,
        init: false,
        setup: true,
        input_path: input_path(state),
        output_path: output_path
      )
    )

    state
  rescue
    error -> Helpers.handle_error(state, "Failed to consolidate", error, __STACKTRACE__)
  end

  @spec seed_data(t()) :: t()
  def seed_data(state) do
    Logger.info("Seeding data")

    case Reseeder.reseed(output_path(state)) do
      :ok -> state
      {:error, {error, stacktrace}} -> Helpers.handle_error(state, "Failed to seed", error, stacktrace)
    end
  end

  @spec update_source(t()) :: t()
  def update_source(%{header: %{updated_at: updated_at}, source_id: source_id} = state) do
    Logger.info("Updating source")

    params = %{
      extraction_date: Date.utc_today(),
      last_update_date: NaiveDateTime.to_date(updated_at)
    }

    with {:error, error} <- Dashboards.Sources.update(source_id, params) do
      Helpers.handle_error(state, "Failed to update source", error)
    end

    state
  end

  @spec backup_data(t()) :: t()
  def backup_data(state) do
    Logger.info("Backing up data")

    output_path = output_path(state)

    if File.dir?(output_path) do
      backup_path = backup_path(state)

      if File.dir?(backup_path) do
        temporary_backup_path = "/tmp/flu_syndrome_updater_backup"

        File.rm_rf!(temporary_backup_path)
        File.cp_r!(backup_path, temporary_backup_path)
        File.rm_rf!(backup_path)

        try do
          File.cp_r!(output_path, backup_path)
        rescue
          _error -> File.cp_r!(temporary_backup_path, backup_path)
        end

        File.rm_rf!(temporary_backup_path)
      else
        File.mkdir_p!(backup_path)
        File.cp_r!(output_path, backup_path)
      end
    end

    File.rm_rf!(output_path)

    state
  rescue
    error -> Helpers.handle_error(state, "Failed to backup data", error, __STACKTRACE__)
  end

  defp backup_path(state), do: Path.join(state.path, "backup")
  defp input_path(state), do: Path.join(state.path, "input")
  defp output_path(state), do: Path.join(state.path, "output")
end
