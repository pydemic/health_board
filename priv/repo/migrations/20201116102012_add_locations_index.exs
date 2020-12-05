defmodule HealthBoard.Repo.Migrations.AddLocationsIndex do
  use Ecto.Migration

  def change do
    create unique_index(:locations, [:context, :id])
  end
end
