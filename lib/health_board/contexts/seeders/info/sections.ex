defmodule HealthBoard.Contexts.Seeders.Sections do
  alias HealthBoard.Contexts.Seeder

  @context "info"
  @table_name "sections"
  @columns ~w[group_id index id name description]a

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
