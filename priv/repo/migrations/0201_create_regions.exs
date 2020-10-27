defmodule HealthRegion.Repo.Migrations.CreateRegions do
  use Ecto.Migration

  def change do
    create table(:regions) do
      add :name, :string
      add :abbr, :string

      add :lat, :float
      add :lng, :float

      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end
  end
end
