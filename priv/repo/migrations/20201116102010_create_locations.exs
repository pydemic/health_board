defmodule HealthBoard.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :level, :integer, null: false

      add :name, :string, null: false
      add :abbr, :string

      add :parent_id, references(:locations, on_delete: :delete_all)
    end
  end
end
