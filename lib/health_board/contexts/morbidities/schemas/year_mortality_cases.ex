defmodule HealthBoard.Contexts.Morbidities.YearMortalityCases do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Geo
  alias HealthBoard.Contexts.Morbidities.YearMortalityCases

  schema "yearly_mortalities_cases" do
    field :disease_context, :integer, null: false
    field :location_context, :integer, null: false

    field :year, :integer, null: false

    field :cases, :integer, default: 0

    field :age_0_4, :integer, default: 0
    field :age_5_9, :integer, default: 0
    field :age_10_14, :integer, default: 0
    field :age_15_19, :integer, default: 0
    field :age_20_24, :integer, default: 0
    field :age_25_29, :integer, default: 0
    field :age_30_34, :integer, default: 0
    field :age_35_39, :integer, default: 0
    field :age_40_44, :integer, default: 0
    field :age_45_49, :integer, default: 0
    field :age_50_54, :integer, default: 0
    field :age_55_59, :integer, default: 0
    field :age_60_64, :integer, default: 0
    field :age_64_69, :integer, default: 0
    field :age_70_74, :integer, default: 0
    field :age_75_79, :integer, default: 0
    field :age_80_or_more, :integer, default: 0
    field :ignored_age_group, :integer, default: 0

    field :male, :integer, default: 0
    field :female, :integer, default: 0
    field :ignored_sex, :integer, default: 0

    field :race_caucasian, :integer, default: 0
    field :race_african, :integer, default: 0
    field :race_asian, :integer, default: 0
    field :race_brown, :integer, default: 0
    field :race_native, :integer, default: 0
    field :ignored_race, :integer, default: 0

    field :fetal, :integer, default: 0
    field :non_fetal, :integer, default: 0
    field :ignored_type, :integer, default: 0

    field :investigated, :integer, default: 0
    field :not_investigated, :integer, default: 0
    field :ignored_investigation, :integer, default: 0

    belongs_to :location, Geo.Location
  end

  @cast_attrs [
    :disease_context,
    :location_context,
    :year,
    :cases,
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
    :age_80_or_more,
    :ignored_age_group,
    :male,
    :female,
    :ignored_sex,
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

  @doc false
  @spec changeset(%YearMortalityCases{}, map()) :: Ecto.Changeset.t()
  def changeset(year_mortality_cases, attrs) do
    year_mortality_cases
    |> cast(attrs, @cast_attrs)
    |> validate_required(@cast_attrs)
    |> unique_constraint([:disease_context, :location_context, :location_id, :year])
  end
end
