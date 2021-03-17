defmodule HealthBoard.Updaters.ICUOccupationsUpdater do
  use GenServer, restart: :permanent
  require Logger
  alias HealthBoard.Contexts.{Consolidations, Dashboards}
  alias HealthBoard.Updaters.{ICUOccupationsUpdater, Helpers, Reseeder}

  @args_keys [
    :reattempt_initial_milliseconds,
    :path,
    :update_at_hour,
    :source_id,
    :source_sid,
    :spreadsheet_api_opts
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
          spreadsheet_updated_at: Date.t() | nil,
          last_spreadsheet_updated_at: Date.t() | nil,
          spreadsheet_api_opts: keyword
        }

  defstruct status: :new,
            statuses: [
              :fetch_data,
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
            path: Path.join(File.cwd!(), ".misc/sandbox/updates/icu_occupations"),
            update_at_hour: 3,
            source_sid: "health_board_hospitalization",
            source_id: nil,
            spreadsheet_updated_at: nil,
            last_spreadsheet_updated_at: nil,
            spreadsheet_api_opts: []

  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    GenServer.start(ICUOccupationsUpdater, args, name: __MODULE__)
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

  @spec fetch_data(t()) :: t()
  def fetch_data(%{spreadsheet_updated_at: spreadsheet_updated_at} = state) do
    Logger.info("Fetching data")

    with {:ok, state} <- update_spreadsheet_api_opts(state),
         {:ok, {_source, state}} <- fetch_source(state),
         {:ok, updated_at} <- ICUOccupationsUpdater.SpreadsheetAPI.get(state.spreadsheet_api_opts) do
      struct(state, last_spreadsheet_updated_at: spreadsheet_updated_at, spreadsheet_updated_at: updated_at)
    else
      {:error, error} -> Helpers.handle_error(state, "Failed to fetch data", error)
    end
  end

  defp update_spreadsheet_api_opts(state) do
    %{id: group_id, name: name} =
      Consolidations.ConsolidationsGroups.fetch_by_name!(:hospitals_capacities, :icu_occupations, :rates)

    {:ok,
     struct(
       state,
       spreadsheet_api_opts:
         Keyword.merge(state.spreadsheet_api_opts,
           group_id: group_id,
           output_path:
             Path.join(output_path(state), "consolidations/daily_locations_consolidations/#{group_id}_#{name}")
         )
     )}
  rescue
    _error -> {:error, :failed_to_fetch_consolidation_group}
  end

  defp fetch_source(%{source_id: id, source_sid: sid} = state) do
    if is_nil(id) do
      case Dashboards.Sources.fetch_by_sid(sid) do
        {:ok, %{id: id} = source} -> {:ok, {source, struct(state, source_id: id)}}
        :error -> {:error, :source_not_found}
      end
    else
      case Dashboards.Sources.fetch(id) do
        {:ok, source} -> {:ok, {source, state}}
        :error -> fetch_source(struct(state, source_id: nil))
      end
    end
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
  def update_source(%{spreadsheet_updated_at: updated_at, source_id: source_id} = state) do
    Logger.info("Updating source")

    params = %{
      extraction_date: Date.utc_today(),
      last_update_date: updated_at
    }

    case Dashboards.Sources.update(source_id, params) do
      {:error, error} -> Helpers.handle_error(state, "Failed to update source", error)
      _result -> state
    end
  end

  @spec backup_data(t()) :: t()
  def backup_data(state) do
    Logger.info("Backing up data")

    output_path = output_path(state)

    if File.dir?(output_path) do
      backup_path = backup_path(state)

      if File.dir?(backup_path) do
        temporary_backup_path = "/tmp/icu_occupations_updater_backup"

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
  defp output_path(state), do: Path.join(state.path, "output")
end
