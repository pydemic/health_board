defmodule HealthBoard.Scripts.Morbidities.WeeklyCompulsories.DengueConsolidator do
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

  @spec run :: :ok
  def run do
    Consolidator.run("dengue", &parse_line/2)
  end

  defp parse_line(line, cities) do
    [year, source_city_id, resident_city_id, age_code, sex, race, classification, serotype] = line

    year = String.to_integer(year)
    resident_city = Consolidator.find_city(cities, resident_city_id)
    source_city = Consolidator.find_city(cities, source_city_id)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      identify_classification(classification),
      identify_serotype(serotype)
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
      "10" -> :confirmed
      "11" -> :confirmed_warning
      "12" -> :confirmed_severe
      "13" -> :confirmed_chikungunya
      _classification -> :ignored_classification
    end
  end

  defp identify_serotype(serotype) do
    case serotype do
      "1" -> :serotype_1
      "2" -> :serotype_2
      "3" -> :serotype_3
      "4" -> :serotype_4
      _serotype -> :ignored_serotype
    end
  end
end
