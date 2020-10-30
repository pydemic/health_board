defmodule HealthBoard.Repo.Migrations.CreateIndicators do
  use Ecto.Migration

  def change do
    create table(:indicators, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string

      add :math, :string
    end
  end
end
