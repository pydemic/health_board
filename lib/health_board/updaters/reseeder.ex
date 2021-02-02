defmodule HealthBoard.Updaters.Reseeder do
  use GenServer
  require Logger
  alias HealthBoard.Contexts.{Consolidations, Seeders}

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_arg) do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @spec reseed(String.t()) :: :ok | {:error, {any, Exception.stacktrace()}}
  def reseed(path) do
    GenServer.call(__MODULE__, {:reseed, path}, :infinity)
  end

  @impl GenServer
  @spec init(any) :: {:ok, :empty}
  def init(_args) do
    {:ok, :empty}
  end

  @impl GenServer
  @spec handle_call(any, {pid, any}, :empty) :: {:reply, any, :empty}
  def handle_call({:reseed, path}, _from, state) do
    {:reply, do_reseed(path), state}
  end

  defp do_reseed(path) do
    path
    |> File.ls!()
    |> Enum.map(&reseed_from_consolidation_type(path, &1))
  rescue
    error -> {:error, {error, __STACKTRACE__}}
  end

  defp reseed_from_consolidation_type(path, consolidation_type) do
    path
    |> Path.join(consolidation_type)
    |> File.ls!()
    |> Enum.map(&reseed_from_group(path, consolidation_type, &1))
  end

  defp reseed_from_group(path, consolidation_type, consolidation_group) do
    [consolidation_group_id | _group] = String.split(consolidation_group, "_", parts: 2)
    path = Path.join(path, consolidation_type)

    case consolidation_type do
      "locations_consolidations" ->
        Consolidations.LocationsConsolidations.delete_by(consolidation_group_id: consolidation_group_id)
        Seeders.Consolidations.LocationsConsolidations.up!(path)

      "yearly_locations_consolidations" ->
        Consolidations.YearlyLocationsConsolidations.delete_by(consolidation_group_id: consolidation_group_id)
        Seeders.Consolidations.YearlyLocationsConsolidations.up!(path)

      "monthly_locations_consolidations" ->
        Consolidations.MonthlyLocationsConsolidations.delete_by(consolidation_group_id: consolidation_group_id)
        Seeders.Consolidations.MonthlyLocationsConsolidations.up!(path)

      "weekly_locations_consolidations" ->
        Consolidations.WeeklyLocationsConsolidations.delete_by(consolidation_group_id: consolidation_group_id)
        Seeders.Consolidations.WeeklyLocationsConsolidations.up!(path)

      "daily_locations_consolidations" ->
        Consolidations.DailyLocationsConsolidations.delete_by(consolidation_group_id: consolidation_group_id)
        Seeders.Consolidations.DailyLocationsConsolidations.up!(path)
    end
  end
end
