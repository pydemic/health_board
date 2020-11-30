defmodule HealthBoard.Scripts.Morbidities.WeeklyCompulsories.TetanusAccidentsConsolidator do
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

  @spec run :: :ok
  def run do
    Consolidator.run("tetanus_accidents", &parse_line/1)
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
      vaccination_history,
      treatment,
      likely_cause,
      likely_source
    ] = line

    year = String.to_integer(year)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      identify_vaccination_history(vaccination_history),
      identify_treatment(treatment),
      identify_likely_cause(likely_cause),
      identify_likely_source(likely_source)
    ]

    {
      resident_city_id,
      source_city_id,
      year,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_vaccination_history(vaccination_history) do
    case vaccination_history do
      "1" -> :vaccinated_1
      "2" -> :vaccinated_2
      "3" -> :vaccinated_3
      "4" -> :vaccinated_3_plus_1
      "5" -> :vaccinated_3_plus_2
      "6" -> :vaccinated_0
      _vaccination_history -> :ignored_vaccination_history
    end
  end

  defp identify_treatment(treatment) do
    case treatment do
      "1" -> :antitetanus_serum_treatment
      "2" -> :immunoglobulin_treatment
      "3" -> :vaccine_treatment
      "4" -> :antibiotic_treatment
      "5" -> :no_treatment
      _treatment -> :ignored_treatment
    end
  end

  defp identify_likely_cause(likely_cause) do
    case likely_cause do
      "1" -> :injection_likely_cause
      "2" -> :laceration_likely_cause
      "3" -> :burn_likely_cause
      "4" -> :surgical_likely_cause
      "5" -> :puncture_likely_cause
      "6" -> :excoriation_likely_cause
      "7" -> :septic_abortion_likely_cause
      "8" -> :other_likely_cause
      _likely_cause -> :ignored_likely_cause
    end
  end

  defp identify_likely_source(likely_source) do
    case likely_source do
      "1" -> :home_likely_source
      "2" -> :work_likely_source
      "3" -> :public_likely_source
      "4" -> :school_likely_source
      "5" -> :rural_likely_source
      "6" -> :health_institution_likely_source
      "7" -> :other_likely_source
      _likely_source -> :ignored_likely_source
    end
  end
end
