defmodule HealthBoard.Updaters.CovidReportsUpdater do
  use GenServer, restart: :permanent
  require Logger
  alias HealthBoard.Contexts.Dashboards
  alias HealthBoard.Updaters.{CovidReportsUpdater, Helpers, Reseeder}

  @args_keys [
    :reattempt_initial_milliseconds,
    :path,
    :update_at_hour,
    :source_id,
    :source_sid,
    :consolidator_opts,
    :header_api_opts
  ]

  @type t :: %__MODULE__{
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
            path: Path.join(File.cwd!(), ".misc/sandbox/updates/covid_reports"),
            update_at_hour: 3,
            source_sid: "health_board_situation_report",
            source_id: nil,
            header: nil,
            last_header: nil,
            consolidator_opts: [],
            header_api_opts: []

  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    GenServer.start(CovidReportsUpdater, args, name: __MODULE__)
  end

  @impl GenServer
  @spec init(keyword) :: {:ok, t()}
  def init(args) do
    CovidReportsUpdater.Consolidator.init()

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
  def new(fields) when is_list(fields), do: struct(__MODULE__, Keyword.take(fields, @args_keys))
  def new(fields) when is_map(fields), do: struct(__MODULE__, Map.take(fields, @args_keys))

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

    case CovidReportsUpdater.HeaderAPI.get(opts) do
      {:ok, header} -> struct(state, header: header, last_header: current_header)
      {:error, error} -> Helpers.handle_error(state, "Failed to fetch header", error)
    end
  end

  @spec download_data(t()) :: t()
  def download_data(%{header: %{url: url} = header, last_header: last_header} = state) do
    Logger.info("Downloading data")

    {source, state} = fetch_source(state)

    if download_data?(header, last_header, source) do
      case String.downcase(Path.extname(url)) do
        ".csv" -> download_csv(state)
        ".zip" -> download_zip(state)
        "" -> Helpers.handle_error(state, "Failed to download data", "URL #{url} is not a file")
        ext -> Helpers.handle_error(state, "Failed to download data", "Extension #{ext} for URL #{url} is invalid")
      end
    else
      Logger.info("Database is updated")
      struct(state, status: :idle)
    end
  end

  defp fetch_source(%{source_id: id, source_sid: sid} = state) do
    if is_nil(id) do
      case Dashboards.Sources.fetch_by_sid(sid) do
        {:ok, %{id: id} = source} -> {source, struct(state, source_id: id)}
        :error -> {nil, state}
      end
    else
      case Dashboards.Sources.fetch_by_sid(id) do
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

  defp download_csv(%{header: %{url: url} = header} = state) do
    input_path = input_path(state)

    File.rm_rf!(input_path)
    File.mkdir_p!(input_path)

    csv_path = Path.join(input_path, Path.basename(url))

    case :httpc.request(:get, {String.to_charlist(url), []}, [], stream: String.to_charlist(csv_path)) do
      {:ok, _result} -> struct(state, last_header: header)
      {:error, error} -> Helpers.handle_error(state, "Failed to download csv data", error)
    end
  end

  defp download_zip(%{header: %{url: url}} = state) do
    input_path = input_path(state)

    File.rm_rf!(input_path)
    File.mkdir_p!(input_path)

    zip_path = Path.join(input_path, Path.basename(url))

    case :httpc.request(:get, {String.to_charlist(url), []}, [], stream: String.to_charlist(zip_path)) do
      {:ok, _result} -> handle_zip_file(state, zip_path)
      {:error, error} -> Helpers.handle_error(state, "Failed to download zip data", error)
    end
  end

  defp handle_zip_file(%{header: header} = state, path) do
    directory = Path.dirname(path)

    result = :zip.unzip(String.to_charlist(path), cwd: String.to_charlist(directory))

    File.rm!(path)

    case result do
      {:ok, [_file_name]} -> struct(state, last_header: header)
      {:ok, _files} -> Helpers.handle_error(state, "Failed to handle data from downloaded zip", "Multiple files")
      {:error, error} -> Helpers.handle_error(state, "Failed to unzip downloaded data", error)
    end
  end

  @spec consolidate_data(t()) :: t()
  def consolidate_data(%{consolidator_opts: opts} = state) do
    Logger.info("Consolidating data")

    output_path = output_path(state)

    File.rm_rf!(output_path)
    File.mkdir_p!(output_path)

    CovidReportsUpdater.ConsolidatorManager.consolidate(
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
        temporary_backup_path = "/tmp/covid_reports_updater_backup"

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
