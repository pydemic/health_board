defmodule HealthBoard.Scripts.Morbidities.Immediates.BotulismConsolidator do
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

  @spec run :: :ok
  def run do
    Consolidator.run("botulism", &parse_line/2)
  end

  defp parse_line(line, cities) do
    [date, source_city_id, resident_city_id, age_code, sex, race, classification, evolution, type] = line

    %{year: year} = Date.from_iso8601!(date)

    resident_city = Consolidator.find_city(cities, resident_city_id)
    source_city = Consolidator.find_city(cities, source_city_id)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      Consolidator.identify_evolution(evolution),
      identify_type(type)
    ]

    {
      resident_city,
      source_city,
      year,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_type(type) do
    case type do
      "1" -> :type_food
      "2" -> :type_intestinal
      "3" -> :type_wound
      "4" -> :other_type
      _type -> :ignored_type
    end
  end
end
