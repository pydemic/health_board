defmodule HealthBoard.Contexts.Seeders.Consolidations.DailyLocationsConsolidations do
  alias HealthBoard.Contexts.Seeder

  @context "consolidations"
  @table_name "daily_locations_consolidations"
  @columns ~w[group_id location_id date total values]a

  @spec down! :: :ok
  def down!, do: Seeder.down!(@table_name)

  @spec reseed!(String.t() | nil) :: :ok
  def reseed!(base_path \\ nil) do
    down!()
    up!(base_path)
  end

  @spec up!(String.t() | nil) :: :ok
  def up!(base_path \\ nil), do: Seeder.csvs_from_context!(@context, @table_name, @columns, base_path)
end
