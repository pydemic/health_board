defmodule HealthBoard.Repo.Migrations.AddYearlyBirthsIndex do
  use Ecto.Migration

  def change do
    create unique_index(:yearly_births, [:context, :year, :location_id])
  end
end
