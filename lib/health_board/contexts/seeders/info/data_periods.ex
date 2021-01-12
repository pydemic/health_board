defmodule HealthBoard.Contexts.Seeders.DataPeriods do
  alias HealthBoard.Contexts.Seeder

  @context "info"
  @table_name "data_periods"
  @columns ~w[data_context context location_id from_date to_date]a

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
