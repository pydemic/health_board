defmodule HealthBoard.Contexts.Seeders.Consolidations do
  @spec down!(keyword) :: :ok
  def down!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)

    if what in [:all, :consolidations, :daily_locations], do: __MODULE__.DailyLocationsConsolidations.down!()
    if what in [:all, :consolidations, :weekly_locations], do: __MODULE__.WeeklyLocationsConsolidations.down!()
    if what in [:all, :consolidations, :monthly_locations], do: __MODULE__.MonthlyLocationsConsolidations.down!()
    if what in [:all, :consolidations, :yearly_locations], do: __MODULE__.YearlyLocationsConsolidations.down!()
    if what in [:all, :consolidations, :locations], do: __MODULE__.LocationsConsolidations.down!()

    if what in [:all, :groups], do: __MODULE__.ConsolidationsGroups.down!()

    :ok
  end

  @spec reseed!(keyword) :: :ok
  def reseed!(opts \\ []) do
    down!(opts)
    up!(opts)
  end

  @spec up!(keyword) :: :ok
  def up!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)
    base_path = Keyword.get(opts, :base_path)

    if what in [:all, :groups], do: __MODULE__.ConsolidationsGroups.up!(base_path)

    if what in [:all, :consolidations, :locations], do: __MODULE__.LocationsConsolidations.up!(base_path)
    if what in [:all, :consolidations, :yearly_locations], do: __MODULE__.YearlyLocationsConsolidations.up!(base_path)
    if what in [:all, :consolidations, :monthly_locations], do: __MODULE__.MonthlyLocationsConsolidations.up!(base_path)
    if what in [:all, :consolidations, :weekly_locations], do: __MODULE__.WeeklyLocationsConsolidations.up!(base_path)
    if what in [:all, :consolidations, :daily_locations], do: __MODULE__.DailyLocationsConsolidations.up!(base_path)

    :ok
  end
end
