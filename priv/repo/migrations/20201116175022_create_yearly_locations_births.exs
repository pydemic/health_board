defmodule HealthBoard.Repo.Migrations.CreateYearlyLocationsBirths do
  use Ecto.Migration

  def change do
    create table(:yearly_locations_births) do
      add :location_context, :integer, null: false

      add :date, :date
      add :year, :integer, null: false
      add :week, :integer

      add :births, :integer, default: 0

      add :mother_age_10_or_less, :integer, default: 0
      add :mother_age_10_14, :integer, default: 0
      add :mother_age_15_19, :integer, default: 0
      add :mother_age_20_24, :integer, default: 0
      add :mother_age_25_29, :integer, default: 0
      add :mother_age_30_34, :integer, default: 0
      add :mother_age_35_39, :integer, default: 0
      add :mother_age_40_44, :integer, default: 0
      add :mother_age_45_49, :integer, default: 0
      add :mother_age_50_54, :integer, default: 0
      add :mother_age_55_59, :integer, default: 0
      add :mother_age_60_or_more, :integer, default: 0
      add :ignored_mother_age, :integer, default: 0

      add :child_male_sex, :integer, default: 0
      add :child_female_sex, :integer, default: 0
      add :ignored_child_sex, :integer, default: 0

      add :vaginal_delivery, :integer, default: 0
      add :cesarean_delivery, :integer, default: 0
      add :other_delivery, :integer, default: 0
      add :ignored_delivery, :integer, default: 0

      add :birth_at_hospital, :integer, default: 0
      add :birth_at_other_health_institution, :integer, default: 0
      add :birth_at_home, :integer, default: 0
      add :birth_at_other_location, :integer, default: 0
      add :ignored_birth_location, :integer, default: 0

      add :gestation_duration_21_or_less, :integer, default: 0
      add :gestation_duration_22_27, :integer, default: 0
      add :gestation_duration_28_31, :integer, default: 0
      add :gestation_duration_32_36, :integer, default: 0
      add :gestation_duration_37_41, :integer, default: 0
      add :gestation_duration_42_or_more, :integer, default: 0
      add :ignored_gestation_duration, :integer, default: 0

      add :child_mass_500_or_less, :integer, default: 0
      add :child_mass_500_999, :integer, default: 0
      add :child_mass_1000_1499, :integer, default: 0
      add :child_mass_1500_2499, :integer, default: 0
      add :child_mass_2500_2999, :integer, default: 0
      add :child_mass_3000_3999, :integer, default: 0
      add :child_mass_4000_or_more, :integer, default: 0
      add :ignored_child_mass, :integer, default: 0

      add :prenatal_consultations_none, :integer, default: 0
      add :prenatal_consultations_1_3, :integer, default: 0
      add :prenatal_consultations_4_6, :integer, default: 0
      add :prenatal_consultations_7_or_more, :integer, default: 0
      add :ignored_prenatal_consultations, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end
end
