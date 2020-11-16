defmodule HealthBoard.Repo.Migrations.AddYearlyLocationsPopulationsIndex do
  use Ecto.Migration

  def change do
    create unique_index(:yearly_locations_populations, [:year, :location_id])
  end
end
