defmodule HealthBoard.Scripts.Morbidities.Immediates.ChikungunyaConsolidator do
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

  @spec run :: :ok
  def run do
    Consolidator.run("chikungunya", &parse_line/2)
  end

  defp parse_line([date, source_city_id, resident_city_id, age_code, sex, race, classification, evolution], cities) do
    %{year: year} = Date.from_iso8601!(date)

    resident_city = Consolidator.find_city(cities, resident_city_id)
    source_city = Consolidator.find_city(cities, source_city_id)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      identify_classification(classification),
      identify_evolution(evolution)
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
      "5" -> :discarded
      "10" -> :other_classification
      "11" -> :other_classification
      "12" -> :other_classification
      "13" -> :confirmed
      _classification -> :ignored_classification
    end
  end

  defp identify_evolution(evolution) do
    case evolution do
      "1" -> :healed
      "2" -> :died_from_disease
      "3" -> :died_from_other_causes
      "4" -> :evolution_in_investigation
      _evolution -> :ignored_evolution
    end
  end
end
