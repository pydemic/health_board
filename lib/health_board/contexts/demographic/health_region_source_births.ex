defmodule HealthBoard.Contexts.Demographic.HealthRegionSourceBirths do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Demographic.HealthRegionSourceBirths
  alias HealthBoard.Contexts.Geo

  schema "health_regions_source_births" do
    field :date, :date
    field :year, :integer
    field :week, :integer

    field :births, :integer, default: 0

    field :mother_age_10_or_less, :integer, default: 0
    field :mother_age_10_14, :integer, default: 0
    field :mother_age_15_19, :integer, default: 0
    field :mother_age_20_24, :integer, default: 0
    field :mother_age_25_29, :integer, default: 0
    field :mother_age_30_34, :integer, default: 0
    field :mother_age_35_39, :integer, default: 0
    field :mother_age_40_44, :integer, default: 0
    field :mother_age_45_49, :integer, default: 0
    field :mother_age_50_54, :integer, default: 0
    field :mother_age_55_59, :integer, default: 0
    field :mother_age_60_or_more, :integer, default: 0
    field :ignored_mother_age, :integer, default: 0

    field :child_male_sex, :integer, default: 0
    field :child_female_sex, :integer, default: 0
    field :ignored_child_sex, :integer, default: 0

    field :vaginal_delivery, :integer, default: 0
    field :cesarean_delivery, :integer, default: 0
    field :other_delivery, :integer, default: 0
    field :ignored_delivery, :integer, default: 0

    field :birth_at_hospital, :integer, default: 0
    field :birth_at_other_health_institution, :integer, default: 0
    field :birth_at_home, :integer, default: 0
    field :birth_at_other_location, :integer, default: 0
    field :ignored_birth_location, :integer, default: 0

    field :gestation_duration_21_or_less, :integer, default: 0
    field :gestation_duration_22_27, :integer, default: 0
    field :gestation_duration_28_31, :integer, default: 0
    field :gestation_duration_32_36, :integer, default: 0
    field :gestation_duration_37_41, :integer, default: 0
    field :gestation_duration_42_or_more, :integer, default: 0
    field :ignored_gestation_duration, :integer, default: 0

    field :child_mass_500_or_less, :integer, default: 0
    field :child_mass_500_999, :integer, default: 0
    field :child_mass_1000_1499, :integer, default: 0
    field :child_mass_1500_2499, :integer, default: 0
    field :child_mass_2500_2999, :integer, default: 0
    field :child_mass_3000_3999, :integer, default: 0
    field :child_mass_4000_or_more, :integer, default: 0
    field :ignored_child_mass, :integer, default: 0

    field :prenatal_consultations_none, :integer, default: 0
    field :prenatal_consultations_1_3, :integer, default: 0
    field :prenatal_consultations_4_6, :integer, default: 0
    field :prenatal_consultations_7_or_more, :integer, default: 0
    field :ignored_prenatal_consultations, :integer, default: 0

    belongs_to :health_region, Geo.HealthRegion
  end

  @cast_attrs [
    :date,
    :year,
    :week,
    :births,
    :mother_age_10_or_less,
    :mother_age_10_14,
    :mother_age_15_19,
    :mother_age_20_24,
    :mother_age_25_29,
    :mother_age_30_34,
    :mother_age_35_39,
    :mother_age_40_44,
    :mother_age_45_49,
    :mother_age_50_54,
    :mother_age_55_59,
    :mother_age_60_or_more,
    :ignored_mother_age,
    :child_male_sex,
    :child_female_sex,
    :ignored_child_sex,
    :vaginal_delivery,
    :cesarean_delivery,
    :other_delivery,
    :ignored_delivery,
    :birth_at_hospital,
    :birth_at_other_health_institution,
    :birth_at_home,
    :birth_at_other_location,
    :ignored_birth_location,
    :gestation_duration_21_or_less,
    :gestation_duration_22_27,
    :gestation_duration_28_31,
    :gestation_duration_32_36,
    :gestation_duration_37_41,
    :gestation_duration_42_or_more,
    :ignored_gestation_duration,
    :child_mass_500_or_less,
    :child_mass_500_999,
    :child_mass_1000_1499,
    :child_mass_1500_2499,
    :child_mass_2500_2999,
    :child_mass_3000_3999,
    :child_mass_4000_or_more,
    :ignored_child_mass,
    :prenatal_consultations_none,
    :prenatal_consultations_1_3,
    :prenatal_consultations_4_6,
    :prenatal_consultations_7_or_more,
    :ignored_prenatal_consultations,
    :health_region_id
  ]

  @doc false
  @spec changeset(%HealthRegionSourceBirths{}, map()) :: Ecto.Changeset.t()
  def changeset(health_region_source_births, attrs) do
    health_region_source_births
    |> cast(attrs, @cast_attrs)
    |> validate_required([:date, :year, :week, :health_region_id])
    |> unique_constraint([:date, :health_region_id])
  end
end
