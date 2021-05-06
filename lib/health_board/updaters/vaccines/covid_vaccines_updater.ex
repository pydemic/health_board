defmodule HealthBoard.Updaters.CovidVaccinesUpdater do
  use GenServer, restart: :permanent
  require Logger
  alias HealthBoard.Contexts.Dashboards
  alias HealthBoard.Updaters.{CovidVaccinesUpdater, Helpers}

  @args_keys [
    :reattempt_initial_milliseconds,
    :path,
    :extractions_path,
    :update_at_hour,
    :source_id,
    :source_sid,
    :header_api_opts
  ]

  @type t :: %CovidVaccinesUpdater{
          status: atom,
          statuses: list(atom),
          error?: boolean,
          attempts: integer,
          reattempt_after_milliseconds: integer,
          reattempt_initial_milliseconds: integer,
          last_error: any,
          last_stacktrace: Exception.stacktrace(),
          path: String.t(),
          extractions_path: String.t(),
          update_at_hour: integer,
          source_sid: String.t(),
          source_id: integer,
          header: map | nil,
          last_header: map | nil,
          header_api_opts: keyword
        }

  defstruct status: :new,
            statuses: [
              :fetch_header,
              :download_data,
              :extract_data,
              :update_source
            ],
            error?: false,
            attempts: 0,
            reattempt_after_milliseconds: 0,
            reattempt_initial_milliseconds: 60_000,
            last_error: nil,
            last_stacktrace: nil,
            path: Path.join(File.cwd!(), ".misc/sandbox/updates/covid_vaccines"),
            extractions_path: Path.join(File.cwd!(), ".misc/sandbox/extractions"),
            update_at_hour: 14,
            source_sid: "covid_vaccines",
            source_id: nil,
            header: nil,
            last_header: nil,
            header_api_opts: []

  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    GenServer.start(CovidVaccinesUpdater, args, name: CovidVaccinesUpdater)
  end

  @impl GenServer
  @spec init(keyword) :: {:ok, t()}
  def init(args) do
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
  def new(fields) when is_list(fields), do: struct(CovidVaccinesUpdater, Keyword.take(fields, @args_keys))
  def new(fields) when is_map(fields), do: struct(CovidVaccinesUpdater, Map.take(fields, @args_keys))

  @spec schedule(t()) :: t()
  def schedule(state) do
    Helpers.schedule_at_hour(state, state.update_at_hour)
  end

  # Steps

  @spec fetch_header(t()) :: t()
  def fetch_header(%{header_api_opts: opts, header: current_header} = state) do
    Logger.info("Fetching header")

    case CovidVaccinesUpdater.HeaderAPI.get(opts) do
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

  @spec extract_data(t()) :: t()
  def extract_data(state) do
    Logger.info("Extracting data for specific contexts")

    CovidVaccinesUpdater.Extractor.extract(input_path(state), extractions_path(state))

    state
  end

  defp extractions_path(state), do: Path.join(state.extractions_path, "covid")
  defp input_path(state), do: Path.join(state.path, "input")
end
