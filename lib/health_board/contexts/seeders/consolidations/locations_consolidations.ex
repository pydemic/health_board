defmodule HealthBoard.Contexts.Seeders.Consolidations.LocationsConsolidations do
  alias HealthBoard.Contexts.Seeder

  @context "consolidations"
  @table_name "locations_consolidations"
  @columns ~w[consolidation_group_id location_id total values from_date to_date]a

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
