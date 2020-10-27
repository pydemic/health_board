defmodule HealthBoard.Repo.Migrations.CreateCities do
  use Ecto.Migration

  def change do
    create table(:cities) do
      add :name, :string
      add :abbr, :string

      add :lat, :float
      add :lng, :float

      add :health_region_id, references(:health_regions, on_delete: :nilify_all)
      add :state_id, references(:states, on_delete: :delete_all), null: false
      add :region_id, references(:regions, on_delete: :delete_all), null: false
      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end
  end
end
