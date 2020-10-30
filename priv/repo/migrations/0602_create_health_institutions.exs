defmodule HealthBoard.Repo.Migrations.CreateHealthInstitutions do
  use Ecto.Migration

  def change do
    create table(:health_institutions) do
      add :name, :string

      add :city_id, references(:cities, on_delete: :delete_all), null: false
    end
  end
end
