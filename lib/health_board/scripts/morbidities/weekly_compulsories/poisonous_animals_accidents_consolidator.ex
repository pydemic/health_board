defmodule HealthBoard.Scripts.Morbidities.WeeklyCompulsories.PoisonousAnimalsAccidentsConsolidator do
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
    :type_snake,
    :type_spider,
    :type_scorpion,
    :type_lizard,
    :type_bee,
    :other_type,
    :ignored_type
  ]

  @spec run :: :ok
  def run do
    Consolidator.run("poisonous_animals_accidents", &parse_line/2)
  end

  defp parse_line(line, cities) do
    [year, source_city_id, resident_city_id, age_code, sex, race, type] = line

    year = String.to_integer(year)
    resident_city = Consolidator.find_city(cities, resident_city_id)
    source_city = Consolidator.find_city(cities, source_city_id)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
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
      "1" -> :type_snake
      "2" -> :type_spider
      "3" -> :type_scorpion
      "4" -> :type_lizard
      "5" -> :type_bee
      "6" -> :other_type
      _type -> :ignored_type
    end
  end
end
