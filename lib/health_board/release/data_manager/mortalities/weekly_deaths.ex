defmodule HealthBoard.Release.DataManager.WeeklyDeaths do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "mortalities"
  @table_name "weekly_deaths"
  @columns [
    :context,
    :location_id,
    :year,
    :week,
    :total,
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
    :ignored_age_gender,
    :race_caucasian,
    :race_african,
    :race_asian,
    :race_brown,
    :race_native,
    :ignored_race,
    :fetal,
    :non_fetal,
    :ignored_type,
    :investigated,
    :not_investigated,
    :ignored_investigation
  ]

  @spec up :: :ok
  def up do
    DataManager.copy!(@context, @table_name, @columns)
  end

  @spec down :: :ok
  def down do
    Repo.query!("TRUNCATE #{@table_name} CASCADE;")
    :ok
  end
end
