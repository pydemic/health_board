defmodule HealthBoard.Contexts.Morbidities.YearMorbidity do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo

  @type schema :: %__MODULE__{}

  schema "yearly_morbidities" do
    field :context, :integer

    field :year, :integer

    field :total, :integer, default: 0

    field :female_0_4, :integer, default: 0
    field :female_10_14, :integer, default: 0
    field :female_15_19, :integer, default: 0
    field :female_20_24, :integer, default: 0
    field :female_25_29, :integer, default: 0
    field :female_30_34, :integer, default: 0
    field :female_35_39, :integer, default: 0
    field :female_40_44, :integer, default: 0
    field :female_45_49, :integer, default: 0
    field :female_5_9, :integer, default: 0
    field :female_50_54, :integer, default: 0
    field :female_55_59, :integer, default: 0
    field :female_60_64, :integer, default: 0
    field :female_65_69, :integer, default: 0
    field :female_70_74, :integer, default: 0
    field :female_75_79, :integer, default: 0
    field :female_80_or_more, :integer, default: 0

    field :male_0_4, :integer, default: 0
    field :male_10_14, :integer, default: 0
    field :male_15_19, :integer, default: 0
    field :male_20_24, :integer, default: 0
    field :male_25_29, :integer, default: 0
    field :male_30_34, :integer, default: 0
    field :male_35_39, :integer, default: 0
    field :male_40_44, :integer, default: 0
    field :male_45_49, :integer, default: 0
    field :male_5_9, :integer, default: 0
    field :male_50_54, :integer, default: 0
    field :male_55_59, :integer, default: 0
    field :male_60_64, :integer, default: 0
    field :male_65_69, :integer, default: 0
    field :male_70_74, :integer, default: 0
    field :male_75_79, :integer, default: 0
    field :male_80_or_more, :integer, default: 0

    field :ignored_age_gender, :integer, default: 0

    field :race_caucasian, :integer, default: 0
    field :race_african, :integer, default: 0
    field :race_asian, :integer, default: 0
    field :race_brown, :integer, default: 0
    field :race_native, :integer, default: 0
    field :ignored_race, :integer, default: 0

    field :confirmed, :integer, default: 0
    field :discarded, :integer, default: 0
    field :ignored_classification, :integer, default: 0

    field :healed, :integer, default: 0
    field :died_from_morbidity, :integer, default: 0
    field :died_from_other_causes, :integer, default: 0
    field :ignored_evolution, :integer, default: 0

    belongs_to :location, Geo.Location
  end
end
