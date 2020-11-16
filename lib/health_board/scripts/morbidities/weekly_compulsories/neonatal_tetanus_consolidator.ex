defmodule HealthBoard.Scripts.Morbidities.WeeklyCompulsories.NeonatalTetanusConsolidator do
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

  @spec run :: :ok
  def run do
    Consolidator.run("neonatal_tetanus", &parse_line/2)
  end

  defp parse_line(line, cities) do
    [
      year,
      source_city_id,
      resident_city_id,
      age_code,
      sex,
      race,
      classification,
      vaccination_history,
      likely_source,
      prenatal_consultations
    ] = line

    year = String.to_integer(year)
    resident_city = Consolidator.find_city(cities, resident_city_id)
    source_city = Consolidator.find_city(cities, source_city_id)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      identify_vaccination_history(vaccination_history),
      identify_likely_source(likely_source),
      identify_prenatal_consultations(prenatal_consultations)
    ]

    {
      resident_city,
      source_city,
      year,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_vaccination_history(vaccination_history) do
    case vaccination_history do
      "1" -> :vaccinated
      "2" -> :not_vaccinated
      _vaccination_history -> :ignored_vaccination_history
    end
  end

  defp identify_likely_source(likely_source) do
    case likely_source do
      "1" -> :health_institution_likely_source
      "2" -> :home_likely_source
      "3" -> :delivery_house_likely_source
      "4" -> :other_likely_source
      _likely_source -> :ignored_likely_source
    end
  end

  defp identify_prenatal_consultations(prenatal_consultations) do
    case prenatal_consultations do
      "1" -> :prenatal_consultations_1
      "2" -> :prenatal_consultations_2
      "3" -> :prenatal_consultations_3_5
      "4" -> :prenatal_consultations_6_or_more
      "5" -> :prenatal_consultations_0
      _prenatal_consultations -> :ignored_prenatal_consultations
    end
  end
end
