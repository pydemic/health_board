defmodule HealthBoard.Repo.Migrations.CreateDashboards do
  use Ecto.Migration

  def change do
    create table(:dashboards, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
    end
  end
end
