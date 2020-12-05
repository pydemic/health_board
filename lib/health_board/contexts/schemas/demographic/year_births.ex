defmodule HealthBoard.Contexts.Demographic.YearBirths do
  use Ecto.Schema

  alias HealthBoard.Contexts.Geo

  @type schema :: %__MODULE__{}

  schema "yearly_births" do
    field :context, :integer, null: false

    field :year, :integer, null: false

    field :total, :integer, default: 0

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

    field :child_male, :integer, default: 0
    field :child_female, :integer, default: 0
    field :ignored_child_gender, :integer, default: 0

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

    belongs_to :location, Geo.Location
  end
end
