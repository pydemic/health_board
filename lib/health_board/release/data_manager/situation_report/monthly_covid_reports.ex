defmodule HealthBoard.Release.DataManager.MonthlyCOVIDReports do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "situation_report"
  @table_name "monthly_covid_reports"
  @columns ~w[location_id year month cases deaths]a

  @spec up :: :ok
  def up do
    @context
    |> Path.join(@table_name)
    |> DataManager.copy_from_dir!(@table_name, @columns)
  end

  @spec down :: :ok
  def down do
    Repo.query!("TRUNCATE #{@table_name} CASCADE;")
    :ok
  end
end
