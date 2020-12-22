defmodule HealthBoard.Contexts.FluSyndrome.DayFluSyndromeCases do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo

  schema "daily_flu_syndrome_cases" do
    field :context, :integer, null: false

    field :date, :date, null: false

    field :confirmed, :integer, default: 0
    field :discarded, :integer, default: 0

    field :female_0_4, :integer, default: 0
    field :female_5_9, :integer, default: 0
    field :female_10_14, :integer, default: 0
    field :female_15_19, :integer, default: 0
    field :female_20_24, :integer, default: 0
    field :female_25_29, :integer, default: 0
    field :female_30_34, :integer, default: 0
    field :female_35_39, :integer, default: 0
    field :female_40_44, :integer, default: 0
    field :female_45_49, :integer, default: 0
    field :female_50_54, :integer, default: 0
    field :female_55_59, :integer, default: 0
    field :female_60_64, :integer, default: 0
    field :female_65_69, :integer, default: 0
    field :female_70_74, :integer, default: 0
    field :female_75_79, :integer, default: 0
    field :female_80_or_more, :integer, default: 0

    field :male_0_4, :integer, default: 0
    field :male_5_9, :integer, default: 0
    field :male_10_14, :integer, default: 0
    field :male_15_19, :integer, default: 0
    field :male_20_24, :integer, default: 0
    field :male_25_29, :integer, default: 0
    field :male_30_34, :integer, default: 0
    field :male_35_39, :integer, default: 0
    field :male_40_44, :integer, default: 0
    field :male_45_49, :integer, default: 0
    field :male_50_54, :integer, default: 0
    field :male_55_59, :integer, default: 0
    field :male_60_64, :integer, default: 0
    field :male_65_69, :integer, default: 0
    field :male_70_74, :integer, default: 0
    field :male_75_79, :integer, default: 0
    field :male_80_or_more, :integer, default: 0

    field :health_professional, :integer, default: 0

    belongs_to :location, Geo.Location
  end
end
