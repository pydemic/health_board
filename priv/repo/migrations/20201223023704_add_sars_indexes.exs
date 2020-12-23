defmodule HealthBoard.Repo.Migrations.AddSARSIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:pandemic_sars_symptoms, [:context, :location_id])
    create unique_index(:pandemic_sars_cases, [:context, :location_id])
    create unique_index(:monthly_sars_cases, [:context, :year, :month, :location_id])
    create unique_index(:weekly_sars_cases, [:context, :year, :week, :location_id])
    create unique_index(:daily_sars_cases, [:context, :date, :location_id])
  end
end
