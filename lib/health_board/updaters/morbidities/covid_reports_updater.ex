defmodule HealthBoard.Updaters.CovidReportsUpdater do
  use GenServer, restart: :permanent
  require Logger
  alias HealthBoard.Contexts.Dashboards
  alias HealthBoard.Updaters.{CovidReportsUpdater, Helpers, Reseeder}

  @args_keys [
    :reattempt_initial_milliseconds,
    :updates_path,
    :source_id,
    :update_at_hour,
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
            source_id: 6,
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

  defp rollback_data(%{path: path}) do
    case Reseeder.reseed(Path.join(path, "backup")) do
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
  def download_data(%{header: %{url: url} = header, last_header: last_header, source_id: source_id} = state) do
    Logger.info("Downloading data")

    if download_data?(header, last_header, source_id) do
      case Path.extname(url) do
        ".zip" -> download_zip(state)
        "" -> Helpers.handle_error(state, "Failed to download data", "URL #{url} is not a file")
        ext -> Helpers.handle_error(state, "Failed to download data", "Extension #{ext} for URL #{url} is invalid")
      end
    else
      Logger.info("Database is updated")
      struct(state, status: :idle)
    end
  end

  defp download_data?(%{updated_at: updated_at}, last_header, source_id) do
    if is_nil(last_header) do
      case Dashboards.Sources.fetch(source_id) do
        {:ok, %{last_update_date: nil}} -> true
        {:ok, %{last_update_date: date}} -> Date.compare(NaiveDateTime.to_date(updated_at), date) == :gt
        _error -> true
      end
    else
      NaiveDateTime.compare(updated_at, last_header.updated_at) == :gt
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
  def consolidate_data(%{consolidator_opts: opts, path: path} = state) do
    Logger.info("Consolidating data")

    output_path = Path.join(path, "output")

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
  def seed_data(%{path: path} = state) do
    Logger.info("Seeding data")

    case Reseeder.reseed(Path.join(path, "output")) do
      :ok -> state
      {:error, {error, stacktrace}} -> Helpers.handle_error(state, "Failed to seed", error, stacktrace)
    end
  end

  @spec update_source(t()) :: t()
  def update_source(%{header: header, source_id: source_id} = state) do
    Logger.info("Updating source")

    case header do
      %{updated_at: updated_at} ->
        params = %{
          extraction_date: Date.utc_today(),
          last_update_date: NaiveDateTime.to_date(updated_at)
        }

        case Dashboards.Sources.update(source_id, params) do
          {:ok, _source} -> state
          {:error, error} -> Helpers.handle_error(state, "Failed to update source", error)
        end
    end
  end

  @spec backup_data(t()) :: t()
  def backup_data(%{path: path} = state) do
    Logger.info("Backing up data")

    output_path = Path.join(path, "output")

    if File.dir?(output_path) do
      backup_path = Path.join(path, "backup")

      if File.dir?(backup_path) do
        temporary_backup_path = Path.join(path, "temporary_backup")

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

  defp input_path(state), do: Path.join(state.path, "input")
end
