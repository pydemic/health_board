defmodule HealthBoard.Repo.Migrations.AddConsolidationsIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:consolidations_groups, [:id, :name])
    create unique_index(:locations_consolidations, [:group_id, :location_id])
    create unique_index(:yearly_locations_consolidations, [:year, :group_id, :location_id])
    create unique_index(:monthly_locations_consolidations, [:year, :month, :group_id, :location_id])
    create unique_index(:weekly_locations_consolidations, [:year, :week, :group_id, :location_id])
    create unique_index(:daily_locations_consolidations, [:date, :group_id, :location_id])
  end
end
