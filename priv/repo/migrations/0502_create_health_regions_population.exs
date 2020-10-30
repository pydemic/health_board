defmodule HealthBoard.Repo.Migrations.CreateHealthRegionsPopulation do
  use Ecto.Migration

  def change do
    create table(:health_regions_population) do
      add :year, :integer

      add :male, :integer
      add :female, :integer

      add :age_0_4, :integer
      add :age_5_9, :integer
      add :age_10_14, :integer
      add :age_15_19, :integer
      add :age_20_24, :integer
      add :age_25_29, :integer
      add :age_30_34, :integer
      add :age_35_39, :integer
      add :age_40_44, :integer
      add :age_45_49, :integer
      add :age_50_54, :integer
      add :age_55_59, :integer
      add :age_60_64, :integer
      add :age_64_69, :integer
      add :age_70_74, :integer
      add :age_75_79, :integer
      add :age_80_or_more, :integer

      add :health_region_id, references(:health_regions, on_delete: :delete_all), null: false
    end

    create unique_index(:health_regions_population, [:year, :health_region_id])
  end
end
