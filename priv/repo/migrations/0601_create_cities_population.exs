defmodule HealthBoard.Repo.Migrations.CreateCitiesPopulation do
  use Ecto.Migration

  def change do
    create table(:cities_population) do
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

      add :city_id, references(:cities, on_delete: :delete_all), null: false
    end
  end
end
