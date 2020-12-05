defmodule HealthBoard.Repo.Migrations.AddYearlyPopulationsIndex do
  use Ecto.Migration

  def change do
    create unique_index(:yearly_populations, [:year, :location_id])
  end
end
