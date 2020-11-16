defmodule HealthBoard.Repo.Migrations.AddYearlyVaccinesCoveragesIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:yearly_vaccines_coverages, [:year, :location_id])
  end
end
