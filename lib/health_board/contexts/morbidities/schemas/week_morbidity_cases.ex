defmodule HealthBoard.Contexts.Morbidities.WeekMorbidityCases do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo

  schema "weekly_morbidities_cases" do
    field :context, :integer, null: false

    field :year, :integer, null: false
    field :week, :integer, null: false

    field :cases, :integer, default: 0

    field :age_0_4_female, :integer, default: 0
    field :age_0_4_male, :integer, default: 0
    field :age_10_14_female, :integer, default: 0
    field :age_10_14_male, :integer, default: 0
    field :age_15_19_female, :integer, default: 0
    field :age_15_19_male, :integer, default: 0
    field :age_20_24_female, :integer, default: 0
    field :age_20_24_male, :integer, default: 0
    field :age_25_29_female, :integer, default: 0
    field :age_25_29_male, :integer, default: 0
    field :age_30_34_female, :integer, default: 0
    field :age_30_34_male, :integer, default: 0
    field :age_35_39_female, :integer, default: 0
    field :age_35_39_male, :integer, default: 0
    field :age_40_44_female, :integer, default: 0
    field :age_40_44_male, :integer, default: 0
    field :age_45_49_female, :integer, default: 0
    field :age_45_49_male, :integer, default: 0
    field :age_5_9_female, :integer, default: 0
    field :age_5_9_male, :integer, default: 0
    field :age_50_54_female, :integer, default: 0
    field :age_50_54_male, :integer, default: 0
    field :age_55_59_female, :integer, default: 0
    field :age_55_59_male, :integer, default: 0
    field :age_60_64_female, :integer, default: 0
    field :age_60_64_male, :integer, default: 0
    field :age_64_69_female, :integer, default: 0
    field :age_64_69_male, :integer, default: 0
    field :age_70_74_female, :integer, default: 0
    field :age_70_74_male, :integer, default: 0
    field :age_75_79_female, :integer, default: 0
    field :age_75_79_male, :integer, default: 0
    field :age_80_or_more_female, :integer, default: 0
    field :age_80_or_more_male, :integer, default: 0
    field :ignored_sex_age_group, :integer, default: 0

    field :race_caucasian, :integer, default: 0
    field :race_african, :integer, default: 0
    field :race_asian, :integer, default: 0
    field :race_brown, :integer, default: 0
    field :race_native, :integer, default: 0
    field :ignored_race, :integer, default: 0

    belongs_to :location, Geo.Location
  end
end
