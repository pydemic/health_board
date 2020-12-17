defmodule HealthBoard.Repo.Migrations.AddLocationsIndex do
  use Ecto.Migration

  def change do
    create unique_index(:locations, [:context, :id])
    create unique_index(:locations_children, [:parent_context, :child_context, :parent_id, :child_id])
  end
end
