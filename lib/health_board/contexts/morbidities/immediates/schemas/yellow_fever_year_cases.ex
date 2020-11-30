defmodule HealthBoard.Contexts.Morbidities.YellowFeverYearCases do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo

  schema "yellow_fever_yearly_cases" do
    field :location_context, :integer, null: false

    field :year, :integer, null: false

    field :cases, :integer, default: 0

    field :age_0_4_male, :integer, default: 0
    field :age_5_9_male, :integer, default: 0
    field :age_10_14_male, :integer, default: 0
    field :age_15_19_male, :integer, default: 0
    field :age_20_24_male, :integer, default: 0
    field :age_25_29_male, :integer, default: 0
    field :age_30_34_male, :integer, default: 0
    field :age_35_39_male, :integer, default: 0
    field :age_40_44_male, :integer, default: 0
    field :age_45_49_male, :integer, default: 0
    field :age_50_54_male, :integer, default: 0
    field :age_55_59_male, :integer, default: 0
    field :age_60_64_male, :integer, default: 0
    field :age_64_69_male, :integer, default: 0
    field :age_70_74_male, :integer, default: 0
    field :age_75_79_male, :integer, default: 0
    field :age_80_or_more_male, :integer, default: 0
    field :age_0_4_female, :integer, default: 0
    field :age_5_9_female, :integer, default: 0
    field :age_10_14_female, :integer, default: 0
    field :age_15_19_female, :integer, default: 0
    field :age_20_24_female, :integer, default: 0
    field :age_25_29_female, :integer, default: 0
    field :age_30_34_female, :integer, default: 0
    field :age_35_39_female, :integer, default: 0
    field :age_40_44_female, :integer, default: 0
    field :age_45_49_female, :integer, default: 0
    field :age_50_54_female, :integer, default: 0
    field :age_55_59_female, :integer, default: 0
    field :age_60_64_female, :integer, default: 0
    field :age_64_69_female, :integer, default: 0
    field :age_70_74_female, :integer, default: 0
    field :age_75_79_female, :integer, default: 0
    field :age_80_or_more_female, :integer, default: 0
    field :ignored_sex_age_group, :integer, default: 0

    field :race_caucasian, :integer, default: 0
    field :race_african, :integer, default: 0
    field :race_asian, :integer, default: 0
    field :race_brown, :integer, default: 0
    field :race_native, :integer, default: 0
    field :ignored_race, :integer, default: 0

    field :confirmed_wild, :integer, default: 0
    field :confirmed_urban, :integer, default: 0
    field :discarded, :integer, default: 0
    field :ignored_classification, :integer, default: 0

    field :healed, :integer, default: 0
    field :died_from_disease, :integer, default: 0
    field :died_from_other_causes, :integer, default: 0
    field :ignored_evolution, :integer, default: 0

    field :applied_vaccine, :integer, default: 0
    field :not_applied_vaccine, :integer, default: 0
    field :ignored_vaccine_application, :integer, default: 0

    belongs_to :location, Geo.Location
  end
end
