defmodule HealthBoard.Repo.Migrations.CreateYearlyLocationsPopulations do
  use Ecto.Migration

  def change do
    create table(:yearly_locations_populations) do
      add :year, :integer, null: false

      add :male, :integer, default: 0
      add :female, :integer, default: 0

      add :age_0_4, :integer, default: 0
      add :age_5_9, :integer, default: 0
      add :age_10_14, :integer, default: 0
      add :age_15_19, :integer, default: 0
      add :age_20_24, :integer, default: 0
      add :age_25_29, :integer, default: 0
      add :age_30_34, :integer, default: 0
      add :age_35_39, :integer, default: 0
      add :age_40_44, :integer, default: 0
      add :age_45_49, :integer, default: 0
      add :age_50_54, :integer, default: 0
      add :age_55_59, :integer, default: 0
      add :age_60_64, :integer, default: 0
      add :age_64_69, :integer, default: 0
      add :age_70_74, :integer, default: 0
      add :age_75_79, :integer, default: 0
      add :age_80_or_more, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end
end
