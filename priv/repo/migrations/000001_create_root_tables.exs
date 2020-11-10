defmodule HealthBoard.Repo.Migrations.CreateRootTables do
  use Ecto.Migration

  def change do
    create table(:countries) do
      add :name, :string
      add :abbr, :string

      add :lat, :float
      add :lng, :float
    end

    create table(:regions) do
      add :name, :string
      add :abbr, :string

      add :lat, :float
      add :lng, :float

      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end

    create table(:states) do
      add :name, :string
      add :abbr, :string

      add :lat, :float
      add :lng, :float

      add :region_id, references(:regions, on_delete: :delete_all), null: false
      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end

    create table(:health_regions) do
      add :name, :string
      add :abbr, :string

      add :lat, :float
      add :lng, :float

      add :state_id, references(:states, on_delete: :delete_all), null: false
      add :region_id, references(:regions, on_delete: :delete_all), null: false
      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end

    create table(:cities) do
      add :name, :string
      add :abbr, :string

      add :lat, :float
      add :lng, :float

      add :health_region_id, references(:health_regions, on_delete: :nilify_all)
      add :state_id, references(:states, on_delete: :delete_all), null: false
      add :region_id, references(:regions, on_delete: :delete_all), null: false
      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end

    create table(:health_institutions) do
      add :name, :string

      add :city_id, references(:cities, on_delete: :delete_all), null: false
    end

    create table(:countries_population) do
      add :year, :integer

      add :male, :integer
      add :female, :integer

      add :age_0_4, :integer
      add :age_5_9, :integer
      add :age_10_14, :integer
      add :age_15_19, :integer
      add :age_20_24, :integer
      add :age_25_29, :integer
      add :age_30_34, :integer
      add :age_35_39, :integer
      add :age_40_44, :integer
      add :age_45_49, :integer
      add :age_50_54, :integer
      add :age_55_59, :integer
      add :age_60_64, :integer
      add :age_64_69, :integer
      add :age_70_74, :integer
      add :age_75_79, :integer
      add :age_80_or_more, :integer

      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end

    create unique_index(:countries_population, [:year, :country_id])

    create table(:regions_population) do
      add :year, :integer

      add :male, :integer
      add :female, :integer

      add :age_0_4, :integer
      add :age_5_9, :integer
      add :age_10_14, :integer
      add :age_15_19, :integer
      add :age_20_24, :integer
      add :age_25_29, :integer
      add :age_30_34, :integer
      add :age_35_39, :integer
      add :age_40_44, :integer
      add :age_45_49, :integer
      add :age_50_54, :integer
      add :age_55_59, :integer
      add :age_60_64, :integer
      add :age_64_69, :integer
      add :age_70_74, :integer
      add :age_75_79, :integer
      add :age_80_or_more, :integer

      add :region_id, references(:regions, on_delete: :delete_all), null: false
    end

    create unique_index(:regions_population, [:year, :region_id])

    create table(:states_population) do
      add :year, :integer

      add :male, :integer
      add :female, :integer

      add :age_0_4, :integer
      add :age_5_9, :integer
      add :age_10_14, :integer
      add :age_15_19, :integer
      add :age_20_24, :integer
      add :age_25_29, :integer
      add :age_30_34, :integer
      add :age_35_39, :integer
      add :age_40_44, :integer
      add :age_45_49, :integer
      add :age_50_54, :integer
      add :age_55_59, :integer
      add :age_60_64, :integer
      add :age_64_69, :integer
      add :age_70_74, :integer
      add :age_75_79, :integer
      add :age_80_or_more, :integer

      add :state_id, references(:states, on_delete: :delete_all), null: false
    end

    create unique_index(:states_population, [:year, :state_id])

    create table(:health_regions_population) do
      add :year, :integer

      add :male, :integer
      add :female, :integer

      add :age_0_4, :integer
      add :age_5_9, :integer
      add :age_10_14, :integer
      add :age_15_19, :integer
      add :age_20_24, :integer
      add :age_25_29, :integer
      add :age_30_34, :integer
      add :age_35_39, :integer
      add :age_40_44, :integer
      add :age_45_49, :integer
      add :age_50_54, :integer
      add :age_55_59, :integer
      add :age_60_64, :integer
      add :age_64_69, :integer
      add :age_70_74, :integer
      add :age_75_79, :integer
      add :age_80_or_more, :integer

      add :health_region_id, references(:health_regions, on_delete: :delete_all), null: false
    end

    create unique_index(:health_regions_population, [:year, :health_region_id])

    create table(:cities_population) do
      add :year, :integer

      add :male, :integer
      add :female, :integer

      add :age_0_4, :integer
      add :age_5_9, :integer
      add :age_10_14, :integer
      add :age_15_19, :integer
      add :age_20_24, :integer
      add :age_25_29, :integer
      add :age_30_34, :integer
      add :age_35_39, :integer
      add :age_40_44, :integer
      add :age_45_49, :integer
      add :age_50_54, :integer
      add :age_55_59, :integer
      add :age_60_64, :integer
      add :age_64_69, :integer
      add :age_70_74, :integer
      add :age_75_79, :integer
      add :age_80_or_more, :integer

      add :city_id, references(:cities, on_delete: :delete_all), null: false
    end

    create unique_index(:cities_population, [:year, :city_id])

    create table(:countries_resident_births) do
      add :date, :date
      add :year, :integer
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

      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end

    create unique_index(:countries_resident_births, [:date, :country_id])

    create table(:countries_source_births) do
      add :date, :date
      add :year, :integer
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

      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end

    create unique_index(:countries_source_births, [:date, :country_id])

    create table(:regions_resident_births) do
      add :date, :date
      add :year, :integer
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

      add :region_id, references(:regions, on_delete: :delete_all), null: false
    end

    create unique_index(:regions_resident_births, [:date, :region_id])

    create table(:regions_source_births) do
      add :date, :date
      add :year, :integer
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

      add :region_id, references(:regions, on_delete: :delete_all), null: false
    end

    create unique_index(:regions_source_births, [:date, :region_id])

    create table(:states_resident_births) do
      add :date, :date
      add :year, :integer
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

      add :state_id, references(:states, on_delete: :delete_all), null: false
    end

    create unique_index(:states_resident_births, [:date, :state_id])

    create table(:states_source_births) do
      add :date, :date
      add :year, :integer
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

      add :state_id, references(:states, on_delete: :delete_all), null: false
    end

    create unique_index(:states_source_births, [:date, :state_id])

    create table(:health_regions_resident_births) do
      add :date, :date
      add :year, :integer
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

      add :health_region_id, references(:health_regions, on_delete: :delete_all), null: false
    end

    create unique_index(:health_regions_resident_births, [:date, :health_region_id])

    create table(:health_regions_source_births) do
      add :date, :date
      add :year, :integer
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

      add :health_region_id, references(:health_regions, on_delete: :delete_all), null: false
    end

    create unique_index(:health_regions_source_births, [:date, :health_region_id])

    create table(:cities_resident_births) do
      add :date, :date
      add :year, :integer
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

      add :city_id, references(:cities, on_delete: :delete_all), null: false
    end

    create unique_index(:cities_resident_births, [:date, :city_id])

    create table(:cities_source_births) do
      add :date, :date
      add :year, :integer
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

      add :city_id, references(:cities, on_delete: :delete_all), null: false
    end

    create unique_index(:cities_source_births, [:date, :city_id])

    create table(:health_institutions_source_births) do
      add :date, :date
      add :year, :integer
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

      add :health_institution_id, references(:health_institutions, on_delete: :delete_all), null: false
    end

    create unique_index(:health_institutions_source_births, [:date, :health_institution_id])

    create table(:countries_resident_yearly_births) do
      add :year, :integer

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

      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end

    create unique_index(:countries_resident_yearly_births, [:year, :country_id])

    create table(:countries_source_yearly_births) do
      add :year, :integer

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

      add :country_id, references(:countries, on_delete: :delete_all), null: false
    end

    create unique_index(:countries_source_yearly_births, [:year, :country_id])

    create table(:regions_resident_yearly_births) do
      add :year, :integer

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

      add :region_id, references(:regions, on_delete: :delete_all), null: false
    end

    create unique_index(:regions_resident_yearly_births, [:year, :region_id])

    create table(:regions_source_yearly_births) do
      add :year, :integer

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

      add :region_id, references(:regions, on_delete: :delete_all), null: false
    end

    create unique_index(:regions_source_yearly_births, [:year, :region_id])

    create table(:states_resident_yearly_births) do
      add :year, :integer

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

      add :state_id, references(:states, on_delete: :delete_all), null: false
    end

    create unique_index(:states_resident_yearly_births, [:year, :state_id])

    create table(:states_source_yearly_births) do
      add :year, :integer

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

      add :state_id, references(:states, on_delete: :delete_all), null: false
    end

    create unique_index(:states_source_yearly_births, [:year, :state_id])

    create table(:health_regions_resident_yearly_births) do
      add :year, :integer

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

      add :health_region_id, references(:health_regions, on_delete: :delete_all), null: false
    end

    create unique_index(:health_regions_resident_yearly_births, [:year, :health_region_id])

    create table(:health_regions_source_yearly_births) do
      add :year, :integer

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

      add :health_region_id, references(:health_regions, on_delete: :delete_all), null: false
    end

    create unique_index(:health_regions_source_yearly_births, [:year, :health_region_id])

    create table(:cities_resident_yearly_births) do
      add :year, :integer

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

      add :city_id, references(:cities, on_delete: :delete_all), null: false
    end

    create unique_index(:cities_resident_yearly_births, [:year, :city_id])

    create table(:cities_source_yearly_births) do
      add :year, :integer

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

      add :city_id, references(:cities, on_delete: :delete_all), null: false
    end

    create unique_index(:cities_source_yearly_births, [:year, :city_id])

    create table(:health_institutions_source_yearly_births) do
      add :year, :integer

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

      add :health_institution_id, references(:health_institutions, on_delete: :delete_all), null: false
    end

    create unique_index(:health_institutions_source_yearly_births, [:year, :health_institution_id])

    create table(:dashboards, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string

      timestamps()
    end

    create table(:filters, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
    end

    create table(:indicators, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string

      add :math, :string
    end

    create table(:sources, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string

      add :link, :string
    end

    create table(:visualizations, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string
    end

    create table(:dashboards_filters) do
      add :value, :string

      add :dashboard_id, references(:dashboards, on_delete: :delete_all, type: :string),
        null: false

      add :filter_id, references(:filters, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:dashboards_filters, [:dashboard_id, :filter_id])

    create table(:indicators_children) do
      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string),
        null: false

      add :child_id, references(:indicators, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:indicators_children, [:indicator_id, :child_id])

    create table(:indicators_visualizations, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string

      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string),
        null: false

      add :visualization_id, references(:visualizations, on_delete: :delete_all, type: :string),
        null: false
    end

    create table(:indicators_sources) do
      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string),
        null: false

      add :source_id, references(:sources, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:indicators_sources, [:indicator_id, :source_id])

    create table(:source_extractions) do
      add :date, :date

      add :source_id, references(:sources, on_delete: :delete_all, type: :string), null: false
    end

    create table(:dashboards_indicators_visualizations) do
      add :dashboard_id, references(:dashboards, on_delete: :delete_all, type: :string),
        null: false

      add :indicator_visualization_id,
          references(:indicators_visualizations, on_delete: :delete_all, type: :string),
          null: false
    end

    create unique_index(:dashboards_indicators_visualizations, [
             :dashboard_id,
             :indicator_visualization_id
           ])
  end
end
