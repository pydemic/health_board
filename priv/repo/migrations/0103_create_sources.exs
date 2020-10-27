defmodule HealthBoard.Repo.Migrations.CreateSources do
  use Ecto.Migration

  def change do
    create table(:sources, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string

      add :link, :string
    end
  end
end
