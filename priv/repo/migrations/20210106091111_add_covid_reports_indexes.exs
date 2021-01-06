defmodule HealthBoard.Repo.Migrations.AddCOVIDReportsIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:yearly_covid_reports, [:year, :location_id])
    create unique_index(:monthly_covid_reports, [:year, :month, :location_id])
    create unique_index(:weekly_covid_reports, [:year, :week, :location_id])
    create unique_index(:daily_covid_reports, [:date, :location_id])
  end
end
