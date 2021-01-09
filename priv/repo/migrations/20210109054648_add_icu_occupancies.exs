defmodule HealthBoard.Repo.Migrations.AddICUOccupancies do
  use Ecto.Migration

  def change do
    create unique_index(:daily_icu_occupancies, [:date, :location_id])
  end
end
