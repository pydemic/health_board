defmodule HealthBoard.Repo.Migrations.CreateHealthRegions do
  use Ecto.Migration

  def change do
    create table(:health_regions) do
      add :name, :string
      add :abbr, :string

      add :lat, :float
      add :lng, :float

      add :state_id, references(:states, on_delete: :delete_all), null: false
      add :region_id, references(:regions, on_delete: :delete_all), null: false
      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end
  end
end
