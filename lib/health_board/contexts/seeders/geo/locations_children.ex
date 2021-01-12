defmodule HealthBoard.Contexts.Seeders.LocationsChildren do
  alias HealthBoard.Contexts.Seeder

  @context "geo"
  @table_name "locations_children"
  @columns ~w[parent_context parent_id child_context child_id]a

  @spec down! :: :ok
  def down!, do: Seeder.down!(@table_name)

  @spec reseed!(String.t() | nil) :: :ok
  def reseed!(base_path \\ nil) do
    down!()
    up!(base_path)
  end

  @spec up!(String.t() | nil) :: :ok
  def up!(base_path \\ nil), do: Seeder.csv_from_context!(@context, @table_name, @columns, base_path)
end
