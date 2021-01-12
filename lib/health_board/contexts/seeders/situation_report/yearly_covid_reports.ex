defmodule HealthBoard.Contexts.Seeders.YearlyCOVIDReports do
  alias HealthBoard.Contexts.Seeder

  @context "situation_report"
  @table_name "yearly_covid_reports"
  @columns ~w[location_id year cases deaths]a

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
