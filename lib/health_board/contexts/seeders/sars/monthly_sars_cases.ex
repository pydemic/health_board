defmodule HealthBoard.Contexts.Seeders.MonthlySARSCases do
  alias HealthBoard.Contexts.Seeder

  @context "sars"
  @table_name "monthly_sars_cases"
  @columns [
    :context,
    :location_id,
    :year,
    :month,
    :confirmed,
    :discarded,
    :samples,
    :female_0_4,
    :female_5_9,
    :female_10_14,
    :female_15_19,
    :female_20_24,
    :female_25_29,
    :female_30_34,
    :female_35_39,
    :female_40_44,
    :female_45_49,
    :female_50_54,
    :female_55_59,
    :female_60_64,
    :female_65_69,
    :female_70_74,
    :female_75_79,
    :female_80_or_more,
    :male_0_4,
    :male_5_9,
    :male_10_14,
    :male_15_19,
    :male_20_24,
    :male_25_29,
    :male_30_34,
    :male_35_39,
    :male_40_44,
    :male_45_49,
    :male_50_54,
    :male_55_59,
    :male_60_64,
    :male_65_69,
    :male_70_74,
    :male_75_79,
    :male_80_or_more,
    :race_caucasian,
    :race_african,
    :race_asian,
    :race_brown,
    :race_native,
    :ignored_race
  ]

  @spec down! :: :ok
  def down!, do: Seeder.down!(@table_name)

  @spec reseed!(String.t() | nil) :: :ok
  def reseed!(base_path \\ nil) do
    up!(base_path)
    down!()
  end

  @spec up!(String.t() | nil) :: :ok
  def up!(base_path \\ nil), do: Seeder.csvs_from_context!(@context, @table_name, @columns, base_path)
end
