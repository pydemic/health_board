defmodule HealthBoard.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :group, :integer, null: false

      add :name, :string, null: false
      add :verbose_name, :string, null: false
      add :abbr, :string

      add :lat, :float, default: 0.0
      add :lng, :float, default: 0.0
    end

    create table(:locations_children) do
      add :parent_group, :integer, null: false
      add :child_group, :integer, null: false

      add :parent_id, references(:locations, on_delete: :delete_all)
      add :child_id, references(:locations, on_delete: :delete_all)
    end
  end
end
