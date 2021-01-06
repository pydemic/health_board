defmodule HealthBoard.Repo.Migrations.SeedCOVIDReports do
  use Ecto.Migration

  alias HealthBoard.Release.DataManager

  def up, do: DataManager.SituationReport.up(:covid_reports)
  def down, do: DataManager.SituationReport.down(:covid_reports)
end
