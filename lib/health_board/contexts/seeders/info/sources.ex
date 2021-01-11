defmodule HealthBoard.Contexts.Seeders.Sources do
  alias HealthBoard.Contexts.Seeder

  @context "info"
  @table_name "sources"
  @columns ~w[id name description link update_rate last_update_date extraction_date]a

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
