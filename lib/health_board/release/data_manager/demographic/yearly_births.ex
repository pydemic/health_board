defmodule HealthBoard.Release.DataManager.YearlyBirths do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "demographic"
  @table_name "yearly_births"
  @columns [
    :context,
    :location_id,
    :year,
    :total,
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
    :child_male,
    :child_female,
    :ignored_child_gender,
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
    :ignored_prenatal_consultations
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
