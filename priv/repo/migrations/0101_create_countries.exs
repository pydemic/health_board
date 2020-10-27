defmodule HealthBoard.Repo.Migrations.CreateCountries do
  use Ecto.Migration

  def change do
    create table(:countries) do
      add :name, :string
      add :abbr, :string

      add :lat, :float
      add :lng, :float
    end
  end
end
