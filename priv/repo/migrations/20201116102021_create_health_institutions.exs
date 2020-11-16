defmodule HealthBoard.Repo.Migrations.CreateHealthInstitutions do
  use Ecto.Migration

  alias HealthBoard.Contexts.Geo.Locations

  def change do
    create table(:health_institutions) do
      add :name, :string, null: false

      add :city_id,
          references(
            :locations,
            on_delete: :delete_all,
            where: [level: Locations.city_level()]
          ),
          null: false
    end
  end
end
