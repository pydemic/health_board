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
    |> Path.join("consolidations")
    |> File.ls!()
    |> Enum.sort()
    |> Enum.each(&reseed_from_consolidation_type(path, &1))
  rescue
    error -> {:error, {error, __STACKTRACE__}}
  end

  defp reseed_from_consolidation_type(path, consolidation_type) do
    {manager, seeder} = consolidation_modules(consolidation_type)

    path
    |> Path.join("consolidations")
    |> Path.join(consolidation_type)
    |> File.ls!()
    |> Enum.sort()
    |> Enum.each(&manager.delete_by(consolidation_group_id: extract_consolidation_group_id(&1)))

    seeder.up!(path)
  end

  defp consolidation_modules(consolidation_type) do
    case consolidation_type do
      "locations_consolidations" ->
        {Consolidations.LocationsConsolidations, Seeders.Consolidations.LocationsConsolidations}

      "yearly_locations_consolidations" ->
        {Consolidations.YearlyLocationsConsolidations, Seeders.Consolidations.YearlyLocationsConsolidations}

      "monthly_locations_consolidations" ->
        {Consolidations.MonthlyLocationsConsolidations, Seeders.Consolidations.MonthlyLocationsConsolidations}

      "weekly_locations_consolidations" ->
        {Consolidations.WeeklyLocationsConsolidations, Seeders.Consolidations.WeeklyLocationsConsolidations}

      "daily_locations_consolidations" ->
        {Consolidations.DailyLocationsConsolidations, Seeders.Consolidations.DailyLocationsConsolidations}
    end
  end

  defp extract_consolidation_group_id(consolidation_group) do
    [consolidation_group_id | _group] = String.split(consolidation_group, "_", parts: 2)
    String.to_integer(consolidation_group_id)
  end
end
