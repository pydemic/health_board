defmodule HealthBoard.Contexts.Seeders.Dashboards do
  alias HealthBoard.Contexts.Seeder

  @context "info"
  @table_name "dashboards"
  @columns ~w[id name description inserted_at updated_at]a

  @spec down! :: :ok
  def down!, do: Seeder.down!(@table_name)

  @spec reseed!(String.t() | nil) :: :ok
  def reseed!(base_path \\ nil) do
    up!(base_path)
    down!()
  end

  @spec up!(String.t() | nil) :: :ok
  def up!(base_path \\ nil), do: Seeder.csv_from_context!(@context, @table_name, @columns, base_path)
end
