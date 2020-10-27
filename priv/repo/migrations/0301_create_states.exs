defmodule HealthBoard.Repo.Migrations.CreateStates do
  use Ecto.Migration

  def change do
    create table(:states) do
      add :name, :string
      add :abbr, :string

      add :lat, :float
      add :lng, :float

      add :region_id, references(:regions, on_delete: :delete_all), null: false
      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end
  end
end
