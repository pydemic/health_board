defmodule HealthBoard.Repo.Migrations.CreateCOVIDReports do
  use Ecto.Migration

  def change do
    create_pandemic_covid_reports()
    create_yearly_covid_reports()
    create_monthly_covid_reports()
    create_weekly_covid_reports()
    create_daily_covid_reports()
  end

  defp create_pandemic_covid_reports do
    create table(:pandemic_covid_reports) do
      common_fields()
    end
  end

  defp create_yearly_covid_reports do
    create table(:yearly_covid_reports) do
      add :year, :integer, null: false
      common_fields()
    end
  end

  defp create_monthly_covid_reports do
    create table(:monthly_covid_reports) do
      add :year, :integer, null: false
      add :month, :integer, null: false
      common_fields()
    end
  end

  defp create_weekly_covid_reports do
    create table(:weekly_covid_reports) do
      add :year, :integer, null: false
      add :week, :integer, null: false
      common_fields()
    end
  end

  defp create_daily_covid_reports do
    create table(:daily_covid_reports) do
      add :date, :date, null: false
      common_fields()
    end
  end

  defp common_fields do
    add :cases, :integer, default: 0
    add :deaths, :integer, default: 0

    add :location_id, references(:locations, on_delete: :delete_all), null: false
  end
end
