defmodule HealthBoard.Repo.Migrations.AddLocationsIndex do
  use Ecto.Migration

  def change do
    create unique_index(:locations, [:level, :id])
  end
end
