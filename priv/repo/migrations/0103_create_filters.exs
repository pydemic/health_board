defmodule HealthBoard.Repo.Migrations.CreateFilters do
  use Ecto.Migration

  def change do
    create table(:filters, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
    end
  end
end
