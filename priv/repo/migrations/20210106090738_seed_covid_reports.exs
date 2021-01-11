defmodule HealthBoard.Repo.Migrations.SeedCOVIDReports do
  use Ecto.Migration

  alias HealthBoard.Contexts.Seeders

  def down, do: Seeders.SituationReport.down!(what: :covid_reports)
  def up, do: Seeders.SituationReport.up!(what: :covid_reports)
end
