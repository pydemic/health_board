defmodule HealthBoard.Repo.Migrations.AddFluSyndromeIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:pandemic_flu_syndrome_cases, [:context, :location_id])
    create unique_index(:monthly_flu_syndrome_cases, [:context, :year, :month, :location_id])
    create unique_index(:weekly_flu_syndrome_cases, [:context, :year, :week, :location_id])
    create unique_index(:daily_flu_syndrome_cases, [:context, :date, :location_id])
  end
end
