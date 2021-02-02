defmodule HealthBoard.Repo.Migrations.AddLocationsIndex do
  use Ecto.Migration

  def change do
    create unique_index(:locations, [:group, :id])
  end
end
