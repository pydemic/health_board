defmodule HealthBoard.Repo.Migrations.SeedYearlyLocationsPopulations do
  use Ecto.Migration

  @context "demographic"
  @table_name "yearly_locations_populations"
  @fields [
    :location_id,
    :year,
    :male,
    :female,
    :age_0_4,
    :age_5_9,
    :age_10_14,
    :age_15_19,
    :age_20_24,
    :age_25_29,
    :age_30_34,
    :age_35_39,
    :age_40_44,
    :age_45_49,
    :age_50_54,
    :age_55_59,
    :age_60_64,
    :age_64_69,
    :age_70_74,
    :age_75_79,
    :age_80_or_more
  ]

  def up do
    HealthBoard.DataManager.copy!(@context, @table_name, @fields)
  end

  def down do
    HealthBoard.Repo.query!("TRUNCATE #{@table_name} CASCADE;")
  end
end
