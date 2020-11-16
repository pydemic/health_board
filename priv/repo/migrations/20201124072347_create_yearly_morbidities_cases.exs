defmodule HealthBoard.Repo.Migrations.CreateYearlyMorbiditiesCases do
  use Ecto.Migration

  def change do
    create_immediates()
    create_weekly_compulsories()
    create_mortalities()
  end

  defp create_immediates do
    create table(:botulism_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()
      evolution()

      add :type_food, :integer, default: 0
      add :type_intestinal, :integer, default: 0
      add :type_wound, :integer, default: 0
      add :other_type, :integer, default: 0
      add :ignored_type, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:chikungunya_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()

      classification()
      add :other_classification, :integer, default: 0

      evolution()
      add :evolution_in_investigation, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:cholera_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()
      evolution()

      add :type_unclean_water, :integer, default: 0
      add :type_sewer_exposure, :integer, default: 0
      add :type_food, :integer, default: 0
      add :type_displacement, :integer, default: 0
      add :other_type, :integer, default: 0
      add :ignored_type, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:hantavirus_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()
      evolution()

      add :type_home, :integer, default: 0
      add :type_work, :integer, default: 0
      add :type_leisure, :integer, default: 0
      add :other_type, :integer, default: 0
      add :ignored_type, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:human_rabies_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()

      add :type_canine, :integer, default: 0
      add :type_feline, :integer, default: 0
      add :type_chiroptera, :integer, default: 0
      add :type_primate, :integer, default: 0
      add :type_fox, :integer, default: 0
      add :type_herbivore, :integer, default: 0
      add :other_type, :integer, default: 0
      add :ignored_type, :integer, default: 0

      add :applied_serum, :integer, default: 0
      add :not_applied_serum, :integer, default: 0
      add :ignored_serum_application, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:malaria_from_extra_amazon_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()

      add :exam_result_negative, :integer, default: 0
      add :exam_result_f, :integer, default: 0
      add :exam_result_f_plus_fg, :integer, default: 0
      add :exam_result_v, :integer, default: 0
      add :exam_result_f_plus_v, :integer, default: 0
      add :exam_result_v_plus_fg, :integer, default: 0
      add :exam_result_fg, :integer, default: 0
      add :ignored_exam_result, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:plague_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()
      evolution()

      add :bubonic_form, :integer, default: 0
      add :pneumonic_form, :integer, default: 0
      add :septisemic_form, :integer, default: 0
      add :other_form, :integer, default: 0
      add :ignored_form, :integer, default: 0

      add :low_gravity, :integer, default: 0
      add :moderate_gravity, :integer, default: 0
      add :high_gravity, :integer, default: 0
      add :ignored_gravity, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:spotted_fever_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()
      evolution()

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:yellow_fever_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()

      add :confirmed_wild, :integer, default: 0
      add :confirmed_urban, :integer, default: 0
      add :discarded, :integer, default: 0
      add :ignored_classification, :integer, default: 0

      evolution()

      add :applied_vaccine, :integer, default: 0
      add :not_applied_vaccine, :integer, default: 0
      add :ignored_vaccine_application, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:zika_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()
      evolution()

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end

  defp create_weekly_compulsories do
    create table(:american_tegumentary_leishmaniasis_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()

      add :hiv_coinfection, :integer, default: 0
      add :no_hiv_coinfection, :integer, default: 0
      add :ignored_hiv_coinfection, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:chagas_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:dengue_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()

      add :confirmed, :integer, default: 0
      add :confirmed_warning, :integer, default: 0
      add :confirmed_severe, :integer, default: 0
      add :confirmed_chikungunya, :integer, default: 0
      add :discarded, :integer, default: 0
      add :ignored_classification, :integer, default: 0

      add :serotype_1, :integer, default: 0
      add :serotype_2, :integer, default: 0
      add :serotype_3, :integer, default: 0
      add :serotype_4, :integer, default: 0
      add :ignored_serotype, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:diphtheria_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:exogenous_intoxications_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()

      add :confirmed, :integer, default: 0
      add :exposure, :integer, default: 0
      add :adverse_reaction, :integer, default: 0
      add :differential_diagnosis, :integer, default: 0
      add :withdrawal_syndrome, :integer, default: 0
      add :ignored_classification, :integer, default: 0

      add :home_exposure, :integer, default: 0
      add :work_exposure, :integer, default: 0
      add :path_to_work_exposure, :integer, default: 0
      add :health_service_exposure, :integer, default: 0
      add :school_exposure, :integer, default: 0
      add :external_environment_exposure, :integer, default: 0
      add :other_exposure_location, :integer, default: 0
      add :ignored_exposure_location, :integer, default: 0

      add :medicine_intoxication, :integer, default: 0
      add :agricultural_pesticide_intoxication, :integer, default: 0
      add :domestic_pesticide_intoxication, :integer, default: 0
      add :public_health_pesticide_intoxication, :integer, default: 0
      add :raticide_intoxication, :integer, default: 0
      add :veterinary_product_intoxication, :integer, default: 0
      add :domestic_product_intoxication, :integer, default: 0
      add :hygiene_product_intoxication, :integer, default: 0
      add :industrial_chemical_intoxication, :integer, default: 0
      add :metal_intoxication, :integer, default: 0
      add :addictive_drug_intoxication, :integer, default: 0
      add :toxic_plant_intoxication, :integer, default: 0
      add :food_intoxication, :integer, default: 0
      add :other_toxic_agent, :integer, default: 0
      add :ignored_toxic_agent, :integer, default: 0

      add :occupational_accident, :integer, default: 0
      add :no_occupational_accident, :integer, default: 0
      add :ignored_occupational_accident, :integer, default: 0

      add :single_acute_exposure, :integer, default: 0
      add :repeated_acute_exposure, :integer, default: 0
      add :chronic_exposure, :integer, default: 0
      add :acute_over_chronic_exposure, :integer, default: 0
      add :ignored_exposure_type, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:leprosy_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()

      add :new_entry, :integer, default: 0
      add :other_health_institution_entry, :integer, default: 0
      add :other_city_entry, :integer, default: 0
      add :other_state_entry, :integer, default: 0
      add :other_country_entry, :integer, default: 0
      add :recurrent_entry, :integer, default: 0
      add :other_reentry, :integer, default: 0
      add :ignored_entry, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:leptospirosis_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()

      add :work_related, :integer, default: 0
      add :not_work_related, :integer, default: 0
      add :ignored_work_related, :integer, default: 0

      add :urban_likely_source, :integer, default: 0
      add :rural_likely_source, :integer, default: 0
      add :periurban_likely_source, :integer, default: 0
      add :ignored_likely_source, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:meningitis_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:neonatal_tetanus_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()

      add :vaccinated, :integer, default: 0
      add :not_vaccinated, :integer, default: 0
      add :ignored_vaccination_history, :integer, default: 0

      add :health_institution_likely_source, :integer, default: 0
      add :home_likely_source, :integer, default: 0
      add :delivery_house_likely_source, :integer, default: 0
      add :other_likely_source, :integer, default: 0
      add :ignored_likely_source, :integer, default: 0

      add :prenatal_consultations_0, :integer, default: 0
      add :prenatal_consultations_1, :integer, default: 0
      add :prenatal_consultations_2, :integer, default: 0
      add :prenatal_consultations_3_5, :integer, default: 0
      add :prenatal_consultations_6_or_more, :integer, default: 0
      add :ignored_prenatal_consultations, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:poisonous_animals_accidents_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()

      add :type_snake, :integer, default: 0
      add :type_spider, :integer, default: 0
      add :type_scorpion, :integer, default: 0
      add :type_lizard, :integer, default: 0
      add :type_bee, :integer, default: 0
      add :other_type, :integer, default: 0
      add :ignored_type, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:schistosomiasis_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:tetanus_accidents_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()

      add :vaccinated_0, :integer, default: 0
      add :vaccinated_1, :integer, default: 0
      add :vaccinated_2, :integer, default: 0
      add :vaccinated_3, :integer, default: 0
      add :vaccinated_3_plus_1, :integer, default: 0
      add :vaccinated_3_plus_2, :integer, default: 0
      add :ignored_vaccination_history, :integer, default: 0

      add :antitetanus_serum_treatment, :integer, default: 0
      add :immunoglobulin_treatment, :integer, default: 0
      add :vaccine_treatment, :integer, default: 0
      add :antibiotic_treatment, :integer, default: 0
      add :no_treatment, :integer, default: 0
      add :ignored_treatment, :integer, default: 0

      add :injection_likely_cause, :integer, default: 0
      add :laceration_likely_cause, :integer, default: 0
      add :burn_likely_cause, :integer, default: 0
      add :surgical_likely_cause, :integer, default: 0
      add :puncture_likely_cause, :integer, default: 0
      add :excoriation_likely_cause, :integer, default: 0
      add :septic_abortion_likely_cause, :integer, default: 0
      add :other_likely_cause, :integer, default: 0
      add :ignored_likely_cause, :integer, default: 0

      add :home_likely_source, :integer, default: 0
      add :work_likely_source, :integer, default: 0
      add :public_likely_source, :integer, default: 0
      add :school_likely_source, :integer, default: 0
      add :rural_likely_source, :integer, default: 0
      add :health_institution_likely_source, :integer, default: 0
      add :other_likely_source, :integer, default: 0
      add :ignored_likely_source, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:tuberculosis_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()

      add :free_condition, :integer, default: 0
      add :non_free_condition, :integer, default: 0
      add :ignored_free_condition, :integer, default: 0

      add :homeless_condition, :integer, default: 0
      add :non_homeless_condition, :integer, default: 0
      add :ignored_homeless_condition, :integer, default: 0

      add :health_professional_condition, :integer, default: 0
      add :non_health_professional_condition, :integer, default: 0
      add :ignored_health_professional_condition, :integer, default: 0

      add :immigrant_condition, :integer, default: 0
      add :non_immigrant_condition, :integer, default: 0
      add :ignored_immigrant_condition, :integer, default: 0

      add :positive_hiv_condition, :integer, default: 0
      add :negative_hiv_condition, :integer, default: 0
      add :to_be_defined_hiv_condition, :integer, default: 0
      add :ignored_hiv_condition, :integer, default: 0

      add :aids_condition, :integer, default: 0
      add :non_aids_condition, :integer, default: 0
      add :ignored_aids_condition, :integer, default: 0

      add :alcohol_condition, :integer, default: 0
      add :non_alcohol_condition, :integer, default: 0
      add :ignored_alcohol_condition, :integer, default: 0

      add :diabetes_condition, :integer, default: 0
      add :non_diabetes_condition, :integer, default: 0
      add :ignored_diabetes_condition, :integer, default: 0

      add :mental_condition, :integer, default: 0
      add :non_mental_condition, :integer, default: 0
      add :ignored_mental_condition, :integer, default: 0

      add :illicit_drugs_condition, :integer, default: 0
      add :non_illicit_drugs_condition, :integer, default: 0
      add :ignored_illicit_drugs_condition, :integer, default: 0

      add :smoking_condition, :integer, default: 0
      add :non_smoking_condition, :integer, default: 0
      add :ignored_smoking_condition, :integer, default: 0

      add :other_conditions, :integer, default: 0
      add :no_other_conditions, :integer, default: 0
      add :ignored_other_conditions, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:violence_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:visceral_leishmaniasis_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()

      add :hiv_coinfection, :integer, default: 0
      add :no_hiv_coinfection, :integer, default: 0
      add :ignored_hiv_coinfection, :integer, default: 0

      add :new_entry, :integer, default: 0
      add :recurrent_entry, :integer, default: 0
      add :transferred_entry, :integer, default: 0
      add :ignored_entry, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:whooping_cough_yearly_cases) do
      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()
      classification()

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end

  defp create_mortalities do
    create table(:yearly_mortalities_cases) do
      add :disease_context, :integer, null: false

      add :location_context, :integer, null: false

      add :year, :integer, null: false

      add :cases, :integer, default: 0

      age_groups()
      sex()
      race()

      add :fetal, :integer, default: 0
      add :non_fetal, :integer, default: 0
      add :ignored_type, :integer, default: 0

      add :investigated, :integer, default: 0
      add :not_investigated, :integer, default: 0
      add :ignored_investigation, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end

  defp age_groups do
    add :age_0_4, :integer, default: 0
    add :age_5_9, :integer, default: 0
    add :age_10_14, :integer, default: 0
    add :age_15_19, :integer, default: 0
    add :age_20_24, :integer, default: 0
    add :age_25_29, :integer, default: 0
    add :age_30_34, :integer, default: 0
    add :age_35_39, :integer, default: 0
    add :age_40_44, :integer, default: 0
    add :age_45_49, :integer, default: 0
    add :age_50_54, :integer, default: 0
    add :age_55_59, :integer, default: 0
    add :age_60_64, :integer, default: 0
    add :age_64_69, :integer, default: 0
    add :age_70_74, :integer, default: 0
    add :age_75_79, :integer, default: 0
    add :age_80_or_more, :integer, default: 0
    add :ignored_age_group, :integer, default: 0
  end

  defp classification do
    add :confirmed, :integer, default: 0
    add :discarded, :integer, default: 0
    add :ignored_classification, :integer, default: 0
  end

  defp evolution do
    add :healed, :integer, default: 0
    add :died_from_disease, :integer, default: 0
    add :died_from_other_causes, :integer, default: 0
    add :ignored_evolution, :integer, default: 0
  end

  defp race do
    add :race_caucasian, :integer, default: 0
    add :race_african, :integer, default: 0
    add :race_asian, :integer, default: 0
    add :race_brown, :integer, default: 0
    add :race_native, :integer, default: 0
    add :ignored_race, :integer, default: 0
  end

  defp sex do
    add :male, :integer, default: 0
    add :female, :integer, default: 0
    add :ignored_sex, :integer, default: 0
  end
end
