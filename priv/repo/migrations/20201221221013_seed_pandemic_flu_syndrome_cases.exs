defmodule HealthBoard.Repo.Migrations.SeedPandemicFluSyndromeCases do
  use Ecto.Migration

  @context "flu_syndrome_cases"
  @table_name "pandemic_flu_syndrome_cases"

  def up do
    HealthBoard.Release.DataManager.copy!(@context, @table_name, pandemic_flu_syndrome_cases_fields())
  end

  def down do
    HealthBoard.Repo.query!("TRUNCATE #{@table_name} CASCADE;")
  end

  defp pandemic_flu_syndrome_cases_fields do
    [
      :registry_context,
      :location_id,
      :confirmed,
      :discarded,
      :female_0_4,
      :male_0_4,
      :female_10_14,
      :male_10_14,
      :female_15_19,
      :male_15_19,
      :female_20_24,
      :male_20_24,
      :female_25_29,
      :male_25_29,
      :female_30_34,
      :male_30_34,
      :female_35_39,
      :male_35_39,
      :female_40_44,
      :male_40_44,
      :female_45_49,
      :male_45_49,
      :female_5_9,
      :male_5_9,
      :female_50_54,
      :male_50_54,
      :female_55_59,
      :male_55_59,
      :female_60_64,
      :male_60_64,
      :female_64_69,
      :male_64_69,
      :female_70_74,
      :male_70_74,
      :female_75_79,
      :male_75_79,
      :female_80_or_more,
      :male_80_or_more,
      :health_professional
    ]
  end
end
