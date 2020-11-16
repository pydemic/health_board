defmodule HealthBoard.Scripts.Morbidities.WeeklyCompulsories.LeptospirosisConsolidator do
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
    :work_related,
    :not_work_related,
    :ignored_work_related,
    :urban_likely_source,
    :rural_likely_source,
    :periurban_likely_source,
    :ignored_likely_source
  ]

  @spec run :: :ok
  def run do
    Consolidator.run("leptospirosis", &parse_line/2)
  end

  defp parse_line(line, cities) do
    [year, source_city_id, resident_city_id, age_code, sex, race, classification, work_related, likely_source] = line

    year = String.to_integer(year)
    resident_city = Consolidator.find_city(cities, resident_city_id)
    source_city = Consolidator.find_city(cities, source_city_id)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      identify_work_related(work_related),
      identify_likely_source(likely_source)
    ]

    {
      resident_city,
      source_city,
      year,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_work_related(work_related) do
    case work_related do
      "1" -> :work_related
      "2" -> :not_work_related
      _work_related -> :ignored_work_related
    end
  end

  defp identify_likely_source(likely_source) do
    case likely_source do
      "1" -> :urban_likely_source
      "2" -> :rural_likely_source
      "3" -> :periurban_likely_source
      _likely_source -> :ignored_likely_source
    end
  end
end
