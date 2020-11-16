defmodule HealthBoard.Scripts.Morbidities.Immediates.YellowFeverConsolidator do
  alias HealthBoard.Scripts.Morbidities.Immediates.Consolidator

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

  @spec run :: :ok
  def run do
    Consolidator.run("yellow_fever", &parse_line/2)
  end

  defp parse_line(line, cities) do
    [date, source_city_id, resident_city_id, age_code, sex, race, classification, evolution, vaccine_application] = line

    %{year: year} = Date.from_iso8601!(date)

    resident_city = Consolidator.find_city(cities, resident_city_id)
    source_city = Consolidator.find_city(cities, source_city_id)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      identify_classification(classification),
      Consolidator.identify_evolution(evolution),
      identify_vaccine_application(vaccine_application)
    ]

    {
      resident_city,
      source_city,
      year,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_classification(classification) do
    case classification do
      "1" -> :confirmed_wild
      "2" -> :confirmed_urban
      "3" -> :discarded
      _classification -> :ignored_classification
    end
  end

  defp identify_vaccine_application(vaccine_application) do
    case vaccine_application do
      "1" -> :applied_vaccine
      "2" -> :not_applied_vaccine
      _vaccine_application -> :ignored_vaccine_application
    end
  end
end
