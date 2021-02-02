defmodule HealthBoard.Repo.Migrations.CreateConsolidations do
  use Ecto.Migration

  def change do
    create_consolidations_groups()
    create_locations_consolidations()
    create_yearly_locations_consolidations()
    create_monthly_locations_consolidations()
    create_weekly_locations_consolidations()
    create_daily_locations_consolidations()
  end

  defp create_consolidations_groups do
    create table(:consolidations_groups) do
      add :name, :string, null: false
    end
  end

  defp create_locations_consolidations do
    create table(:locations_consolidations) do
      add :from_date, :date
      add :to_date, :date

      add :total, :integer
      add :values, :text

      add :consolidation_group_id, references(:consolidations_groups, on_delete: :delete_all), null: false
      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end

  defp create_yearly_locations_consolidations do
    create table(:yearly_locations_consolidations) do
      add :year, :integer, null: false

      add :total, :integer
      add :values, :text

      add :consolidation_group_id, references(:consolidations_groups, on_delete: :delete_all), null: false
      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end

  defp create_monthly_locations_consolidations do
    create table(:monthly_locations_consolidations) do
      add :year, :integer, null: false
      add :month, :integer, null: false

      add :total, :integer
      add :values, :text

      add :consolidation_group_id, references(:consolidations_groups, on_delete: :delete_all), null: false
      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end

  defp create_weekly_locations_consolidations do
    create table(:weekly_locations_consolidations) do
      add :year, :integer, null: false
      add :week, :integer, null: false

      add :total, :integer
      add :values, :text

      add :consolidation_group_id, references(:consolidations_groups, on_delete: :delete_all), null: false
      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end

  defp create_daily_locations_consolidations do
    create table(:daily_locations_consolidations) do
      add :date, :date, null: false

      add :total, :integer
      add :values, :text

      add :consolidation_group_id, references(:consolidations_groups, on_delete: :delete_all), null: false
      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end
end
