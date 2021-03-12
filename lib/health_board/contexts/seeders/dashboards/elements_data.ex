defmodule HealthBoard.Contexts.Seeders.Dashboards.ElementsData do
  alias HealthBoard.Contexts.Seeder

  @context "dashboards"
  @table_name "elements_data"
  @columns ~w[id element_id field data_module data_function data_params]a

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
