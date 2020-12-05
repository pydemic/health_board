defmodule HealthBoard.Repo.Migrations.AddMorbiditiesAndDeathsIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:weekly_deaths, [:context, :location_id, :year, :week])
    create unique_index(:weekly_morbidities, [:context, :location_id, :year, :week])
    create unique_index(:yearly_deaths, [:context, :location_id, :year])
    create unique_index(:yearly_morbidities, [:context, :location_id, :year])
  end
end
