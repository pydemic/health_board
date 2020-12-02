defmodule HealthBoard.Scripts.Morbidities.WeeklyCompulsories.ExogenousIntoxicationsConsolidator do
  alias HealthBoard.Scripts.Morbidities.WeeklyCompulsories.Consolidator

  @columns [
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

  @spec run :: :ok
  def run do
    Consolidator.run("exogenous_intoxications", &parse_line/1)
  end

  defp parse_line(line) do
    [
      year,
      source_city_id,
      resident_city_id,
      age_code,
      sex,
      race,
      classification,
      exposure_location,
      toxic_agent,
      occupational_accident,
      exposure_type
    ] = line

    year = String.to_integer(year)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      identify_classification(classification),
      identify_exposure_location(exposure_location),
      identify_toxic_agent(toxic_agent),
      identify_occupational_accident(occupational_accident),
      identify_exposure_type(exposure_type)
    ]

    {
      resident_city_id,
      source_city_id,
      year,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_classification(classification) do
    case classification do
      "1" -> :confirmed
      "2" -> :exposure
      "3" -> :adverse_reaction
      "4" -> :differential_diagnosis
      "5" -> :withdrawal_syndrome
      _classification -> :ignored_classification
    end
  end

  defp identify_exposure_location(exposure_location) do
    case exposure_location do
      "1" -> :home_exposure
      "2" -> :work_exposure
      "3" -> :path_to_work_exposure
      "4" -> :health_service_exposure
      "5" -> :school_exposure
      "6" -> :external_environment_exposure
      "7" -> :other_exposure_location
      _exposure_location -> :ignored_exposure_location
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp identify_toxic_agent(toxic_agent) do
    case toxic_agent do
      "1" -> :medicine_intoxication
      "2" -> :agricultural_pesticide_intoxication
      "3" -> :domestic_pesticide_intoxication
      "4" -> :public_health_pesticide_intoxication
      "5" -> :raticide_intoxication
      "6" -> :veterinary_product_intoxication
      "7" -> :domestic_product_intoxication
      "8" -> :hygiene_product_intoxication
      "9" -> :industrial_chemical_intoxication
      "10" -> :metal_intoxication
      "11" -> :addictive_drug_intoxication
      "12" -> :toxic_plant_intoxication
      "13" -> :food_intoxication
      "14" -> :other_toxic_agent
      _toxic_agent -> :ignored_toxic_agent
    end
  end

  defp identify_occupational_accident(occupational_accident) do
    case occupational_accident do
      "1" -> :occupational_accident
      "2" -> :no_occupational_accident
      _occupational_accident -> :ignored_occupational_accident
    end
  end

  defp identify_exposure_type(exposure_type) do
    case exposure_type do
      "1" -> :single_acute_exposure
      "2" -> :repeated_acute_exposure
      "3" -> :chronic_exposure
      "4" -> :acute_over_chronic_exposure
      _exposure_type -> :ignored_exposure_type
    end
  end
end
