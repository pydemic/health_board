defmodule HealthBoard.Repo.Migrations.SeedMorbiditiesCases do
  use Ecto.Migration

  @context "morbidities"

  @immediates Path.join(@context, "immediates")
  @weekly_compulsories Path.join(@context, "weekly_compulsories")

  def up do
    @context
    |> Path.join("yearly_morbidities_cases")
    |> HealthBoard.DataManager.copy_from_dir!(
      "yearly_morbidities_cases",
      yearly_morbidities_cases_columns()
    )

    @context
    |> Path.join("weekly_morbidities_cases")
    |> HealthBoard.DataManager.copy_from_dir!(
      "weekly_morbidities_cases",
      weekly_morbidities_cases_columns()
    )

    seed_immediate("botulism", botulism_fields())
    seed_immediate("chikungunya", chikungunya_fields())
    seed_immediate("cholera", cholera_fields())
    seed_immediate("hantavirus", hantavirus_fields())
    seed_immediate("human_rabies", human_rabies_fields())
    seed_immediate("malaria", malaria_fields())
    seed_immediate("plague", plague_fields())
    seed_immediate("spotted_fever", spotted_fever_fields())
    seed_immediate("yellow_fever", yellow_fever_fields())
    seed_immediate("zika", zika_fields())

    seed_table(
      @weekly_compulsories,
      "american_tegumentary_leishmaniasis",
      american_tegumentary_leishmaniasis_fields()
    )

    seed_table(@weekly_compulsories, "chagas", chagas_fields())
    seed_table(@weekly_compulsories, "dengue", dengue_fields())
    seed_table(@weekly_compulsories, "diphtheria", diphtheria_fields())
    seed_table(@weekly_compulsories, "exogenous_intoxications", exogenous_intoxications_fields())
    seed_table(@weekly_compulsories, "leprosy", leprosy_fields())
    seed_table(@weekly_compulsories, "leptospirosis", leptospirosis_fields())
    seed_table(@weekly_compulsories, "meningitis", meningitis_fields())
    seed_table(@weekly_compulsories, "neonatal_tetanus", neonatal_tetanus_fields())

    seed_table(
      @weekly_compulsories,
      "poisonous_animals_accidents",
      poisonous_animals_accidents_fields()
    )

    seed_table(@weekly_compulsories, "schistosomiasis", schistosomiasis_fields())
    seed_table(@weekly_compulsories, "tetanus_accidents", tetanus_accidents_fields())
    seed_table(@weekly_compulsories, "tuberculosis", tuberculosis_fields())
    seed_table(@weekly_compulsories, "violence", violence_fields())
    seed_table(@weekly_compulsories, "visceral_leishmaniasis", visceral_leishmaniasis_fields())
    seed_table(@weekly_compulsories, "whooping_cough", whooping_cough_fields())

    HealthBoard.DataManager.copy!(@context, "yearly_mortalities_cases", mortalities_fields())
  end

  def down do
    drop_immediate("botulism")
    drop_immediate("chikungunya")
    drop_immediate("cholera")
    drop_immediate("hantavirus")
    drop_immediate("human_rabies")
    drop_immediate("malaria")
    drop_immediate("plague")
    drop_immediate("spotted_fever")
    drop_immediate("yellow_fever")
    drop_immediate("zika")

    drop_table("american_tegumentary_leishmaniasis")
    drop_table("chagas")
    drop_table("dengue")
    drop_table("diphtheria")
    drop_table("exogenous_intoxications")
    drop_table("leprosy")
    drop_table("leptospirosis")
    drop_table("meningitis")
    drop_table("neonatal_tetanus")
    drop_table("poisonous_animals_accidents")
    drop_table("schistosomiasis")
    drop_table("tetanus_accidents")
    drop_table("tuberculosis")
    drop_table("violence")
    drop_table("visceral_leishmaniasis")
    drop_table("whooping_cough")

    HealthBoard.Repo.query!("TRUNCATE weekly_morbidities_cases CASCADE;")
    HealthBoard.Repo.query!("TRUNCATE yearly_mortalities_cases CASCADE;")
    HealthBoard.Repo.query!("TRUNCATE yearly_morbidities_cases CASCADE;")
  end

  defp seed_table(context, table_name, fields) do
    HealthBoard.DataManager.copy!(context, "#{table_name}_yearly_cases", fields)
  end

  defp seed_immediate(table_name, fields) do
    @immediates
    |> Path.join("#{table_name}_yearly_cases.csv")
    |> HealthBoard.DataManager.copy_from_path!("yearly_#{table_name}_cases", fields)
  end

  defp drop_immediate(table_name) do
    HealthBoard.Repo.query!("TRUNCATE yearly_#{table_name}_cases CASCADE;")
  end

  defp drop_table(table_name) do
    HealthBoard.Repo.query!("TRUNCATE #{table_name}_yearly_cases CASCADE;")
  end

  defp botulism_fields do
    [
      :context,
      :location_id,
      :year,
      :confirmed,
      :discarded,
      :ignored_classification,
      :healed,
      :died_from_disease,
      :died_from_other_causes,
      :ignored_evolution,
      :type_food,
      :type_intestinal,
      :type_wound,
      :other_type,
      :ignored_type
    ]
  end

  defp chikungunya_fields do
    [
      :context,
      :location_id,
      :year,
      :confirmed,
      :discarded,
      :other_classification,
      :ignored_classification,
      :healed,
      :died_from_disease,
      :died_from_other_causes,
      :evolution_in_investigation,
      :ignored_evolution
    ]
  end

  defp cholera_fields do
    [
      :context,
      :location_id,
      :year,
      :confirmed,
      :discarded,
      :ignored_classification,
      :healed,
      :died_from_disease,
      :died_from_other_causes,
      :ignored_evolution,
      :type_unclean_water,
      :type_sewer_exposure,
      :type_food,
      :type_displacement,
      :other_type,
      :ignored_type
    ]
  end

  defp hantavirus_fields do
    [
      :context,
      :location_id,
      :year,
      :confirmed,
      :discarded,
      :ignored_classification,
      :healed,
      :died_from_disease,
      :died_from_other_causes,
      :ignored_evolution,
      :type_home,
      :type_work,
      :type_leisure,
      :other_type,
      :ignored_type
    ]
  end

  defp human_rabies_fields do
    [
      :context,
      :location_id,
      :year,
      :confirmed,
      :discarded,
      :ignored_classification,
      :type_canine,
      :type_feline,
      :type_chiroptera,
      :type_primate,
      :type_fox,
      :type_herbivore,
      :other_type,
      :ignored_type,
      :applied_serum,
      :not_applied_serum,
      :ignored_serum_application
    ]
  end

  defp malaria_fields do
    [
      :context,
      :location_id,
      :year,
      :confirmed,
      :discarded,
      :ignored_classification,
      :exam_result_negative,
      :exam_result_f,
      :exam_result_f_plus_fg,
      :exam_result_v,
      :exam_result_f_plus_v,
      :exam_result_v_plus_fg,
      :exam_result_fg,
      :ignored_exam_result
    ]
  end

  defp plague_fields do
    [
      :context,
      :location_id,
      :year,
      :confirmed,
      :discarded,
      :ignored_classification,
      :healed,
      :died_from_disease,
      :died_from_other_causes,
      :ignored_evolution,
      :bubonic_form,
      :pneumonic_form,
      :septisemic_form,
      :other_form,
      :ignored_form,
      :low_gravity,
      :moderate_gravity,
      :high_gravity,
      :ignored_gravity
    ]
  end

  defp spotted_fever_fields do
    [
      :context,
      :location_id,
      :year,
      :confirmed,
      :discarded,
      :ignored_classification,
      :healed,
      :died_from_disease,
      :died_from_other_causes,
      :ignored_evolution
    ]
  end

  defp yellow_fever_fields do
    [
      :context,
      :location_id,
      :year,
      :confirmed_wild,
      :confirmed_urban,
      :discarded,
      :ignored_classification,
      :healed,
      :died_from_disease,
      :died_from_other_causes,
      :ignored_evolution,
      :applied_vaccine,
      :not_applied_vaccine,
      :ignored_vaccine_application
    ]
  end

  defp zika_fields do
    [
      :context,
      :location_id,
      :year,
      :confirmed,
      :discarded,
      :ignored_classification,
      :healed,
      :died_from_disease,
      :died_from_other_causes,
      :ignored_evolution
    ]
  end

  defp american_tegumentary_leishmaniasis_fields do
    [
      :location_context,
      :location_id,
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
      :hiv_coinfection,
      :no_hiv_coinfection,
      :ignored_hiv_coinfection
    ]
  end

  defp chagas_fields do
    [
      :location_context,
      :location_id,
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
      :confirmed,
      :discarded,
      :ignored_classification
    ]
  end

  defp dengue_fields do
    [
      :location_context,
      :location_id,
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
      :confirmed,
      :confirmed_warning,
      :confirmed_severe,
      :confirmed_chikungunya,
      :discarded,
      :ignored_classification,
      :serotype_1,
      :serotype_2,
      :serotype_3,
      :serotype_4,
      :ignored_serotype
    ]
  end

  defp diphtheria_fields do
    [
      :location_context,
      :location_id,
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
      :confirmed,
      :discarded,
      :ignored_classification
    ]
  end

  defp exogenous_intoxications_fields do
    [
      :location_context,
      :location_id,
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
      :confirmed,
      :exposure,
      :adverse_reaction,
      :differential_diagnosis,
      :withdrawal_syndrome,
      :ignored_classification,
      :home_exposure,
      :work_exposure,
      :path_to_work_exposure,
      :health_service_exposure,
      :school_exposure,
      :external_environment_exposure,
      :other_exposure_location,
      :ignored_exposure_location,
      :medicine_intoxication,
      :agricultural_pesticide_intoxication,
      :domestic_pesticide_intoxication,
      :public_health_pesticide_intoxication,
      :raticide_intoxication,
      :veterinary_product_intoxication,
      :domestic_product_intoxication,
      :hygiene_product_intoxication,
      :industrial_chemical_intoxication,
      :metal_intoxication,
      :addictive_drug_intoxication,
      :toxic_plant_intoxication,
      :food_intoxication,
      :other_toxic_agent,
      :ignored_toxic_agent,
      :occupational_accident,
      :no_occupational_accident,
      :ignored_occupational_accident,
      :single_acute_exposure,
      :repeated_acute_exposure,
      :chronic_exposure,
      :acute_over_chronic_exposure,
      :ignored_exposure_type
    ]
  end

  defp leprosy_fields do
    [
      :location_context,
      :location_id,
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
      :new_entry,
      :other_health_institution_entry,
      :other_city_entry,
      :other_state_entry,
      :other_country_entry,
      :recurrent_entry,
      :other_reentry,
      :ignored_entry
    ]
  end

  defp leptospirosis_fields do
    [
      :location_context,
      :location_id,
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
      :confirmed,
      :discarded,
      :ignored_classification,
      :work_related,
      :not_work_related,
      :ignored_work_related,
      :urban_likely_source,
      :rural_likely_source,
      :periurban_likely_source,
      :ignored_likely_source
    ]
  end

  defp meningitis_fields do
    [
      :location_context,
      :location_id,
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
      :confirmed,
      :discarded,
      :ignored_classification
    ]
  end

  defp neonatal_tetanus_fields do
    [
      :location_context,
      :location_id,
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
      :confirmed,
      :discarded,
      :ignored_classification,
      :vaccinated,
      :not_vaccinated,
      :ignored_vaccination_history,
      :health_institution_likely_source,
      :home_likely_source,
      :delivery_house_likely_source,
      :other_likely_source,
      :ignored_likely_source,
      :prenatal_consultations_0,
      :prenatal_consultations_1,
      :prenatal_consultations_2,
      :prenatal_consultations_3_5,
      :prenatal_consultations_6_or_more,
      :ignored_prenatal_consultations
    ]
  end

  defp poisonous_animals_accidents_fields do
    [
      :location_context,
      :location_id,
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
      :type_snake,
      :type_spider,
      :type_scorpion,
      :type_lizard,
      :type_bee,
      :other_type,
      :ignored_type
    ]
  end

  defp schistosomiasis_fields do
    [
      :location_context,
      :location_id,
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
      :ignored_race
    ]
  end

  defp tetanus_accidents_fields do
    [
      :location_context,
      :location_id,
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
      :confirmed,
      :discarded,
      :ignored_classification,
      :vaccinated_0,
      :vaccinated_1,
      :vaccinated_2,
      :vaccinated_3,
      :vaccinated_3_plus_1,
      :vaccinated_3_plus_2,
      :ignored_vaccination_history,
      :antitetanus_serum_treatment,
      :immunoglobulin_treatment,
      :vaccine_treatment,
      :antibiotic_treatment,
      :no_treatment,
      :ignored_treatment,
      :injection_likely_cause,
      :laceration_likely_cause,
      :burn_likely_cause,
      :surgical_likely_cause,
      :puncture_likely_cause,
      :excoriation_likely_cause,
      :septic_abortion_likely_cause,
      :other_likely_cause,
      :ignored_likely_cause,
      :home_likely_source,
      :work_likely_source,
      :public_likely_source,
      :school_likely_source,
      :rural_likely_source,
      :health_institution_likely_source,
      :other_likely_source,
      :ignored_likely_source
    ]
  end

  defp tuberculosis_fields do
    [
      :location_context,
      :location_id,
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
      :free_condition,
      :non_free_condition,
      :ignored_free_condition,
      :homeless_condition,
      :non_homeless_condition,
      :ignored_homeless_condition,
      :health_professional_condition,
      :non_health_professional_condition,
      :ignored_health_professional_condition,
      :immigrant_condition,
      :non_immigrant_condition,
      :ignored_immigrant_condition,
      :positive_hiv_condition,
      :negative_hiv_condition,
      :to_be_defined_hiv_condition,
      :ignored_hiv_condition,
      :aids_condition,
      :non_aids_condition,
      :ignored_aids_condition,
      :alcohol_condition,
      :non_alcohol_condition,
      :ignored_alcohol_condition,
      :diabetes_condition,
      :non_diabetes_condition,
      :ignored_diabetes_condition,
      :mental_condition,
      :non_mental_condition,
      :ignored_mental_condition,
      :illicit_drugs_condition,
      :non_illicit_drugs_condition,
      :ignored_illicit_drugs_condition,
      :smoking_condition,
      :non_smoking_condition,
      :ignored_smoking_condition,
      :other_conditions,
      :no_other_conditions,
      :ignored_other_conditions
    ]
  end

  defp violence_fields do
    [
      :location_context,
      :location_id,
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
      :ignored_race
    ]
  end

  defp visceral_leishmaniasis_fields do
    [
      :location_context,
      :location_id,
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
      :confirmed,
      :discarded,
      :ignored_classification,
      :hiv_coinfection,
      :no_hiv_coinfection,
      :ignored_hiv_coinfection,
      :new_entry,
      :recurrent_entry,
      :transferred_entry,
      :ignored_entry
    ]
  end

  defp whooping_cough_fields do
    [
      :location_context,
      :location_id,
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
      :confirmed,
      :discarded,
      :ignored_classification
    ]
  end

  defp mortalities_fields do
    [
      :disease_context,
      :location_context,
      :location_id,
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
  end

  defp weekly_morbidities_cases_columns do
    [
      :context,
      :location_id,
      :year,
      :week,
      :cases,
      :age_0_4_female,
      :age_0_4_male,
      :age_10_14_female,
      :age_10_14_male,
      :age_15_19_female,
      :age_15_19_male,
      :age_20_24_female,
      :age_20_24_male,
      :age_25_29_female,
      :age_25_29_male,
      :age_30_34_female,
      :age_30_34_male,
      :age_35_39_female,
      :age_35_39_male,
      :age_40_44_female,
      :age_40_44_male,
      :age_45_49_female,
      :age_45_49_male,
      :age_5_9_female,
      :age_5_9_male,
      :age_50_54_female,
      :age_50_54_male,
      :age_55_59_female,
      :age_55_59_male,
      :age_60_64_female,
      :age_60_64_male,
      :age_64_69_female,
      :age_64_69_male,
      :age_70_74_female,
      :age_70_74_male,
      :age_75_79_female,
      :age_75_79_male,
      :age_80_or_more_female,
      :age_80_or_more_male,
      :ignored_sex_age_group,
      :race_caucasian,
      :race_african,
      :race_asian,
      :race_brown,
      :race_native,
      :ignored_race
    ]
  end

  defp yearly_morbidities_cases_columns do
    [
      :context,
      :location_id,
      :year,
      :cases,
      :age_0_4_female,
      :age_0_4_male,
      :age_10_14_female,
      :age_10_14_male,
      :age_15_19_female,
      :age_15_19_male,
      :age_20_24_female,
      :age_20_24_male,
      :age_25_29_female,
      :age_25_29_male,
      :age_30_34_female,
      :age_30_34_male,
      :age_35_39_female,
      :age_35_39_male,
      :age_40_44_female,
      :age_40_44_male,
      :age_45_49_female,
      :age_45_49_male,
      :age_5_9_female,
      :age_5_9_male,
      :age_50_54_female,
      :age_50_54_male,
      :age_55_59_female,
      :age_55_59_male,
      :age_60_64_female,
      :age_60_64_male,
      :age_64_69_female,
      :age_64_69_male,
      :age_70_74_female,
      :age_70_74_male,
      :age_75_79_female,
      :age_75_79_male,
      :age_80_or_more_female,
      :age_80_or_more_male,
      :ignored_sex_age_group,
      :race_caucasian,
      :race_african,
      :race_asian,
      :race_brown,
      :race_native,
      :ignored_race
    ]
  end
end
