defmodule HealthBoard.Scripts.Morbidities.Immediates.HumanRabiesConsolidator do
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

  @spec run :: :ok
  def run do
    Consolidator.run("human_rabies", &parse_line/2)
  end

  defp parse_line(line, cities) do
    [date, source_city_id, resident_city_id, age_code, sex, race, classification, type, serum_application] = line

    %{year: year} = Date.from_iso8601!(date)

    resident_city = Consolidator.find_city(cities, resident_city_id)
    source_city = Consolidator.find_city(cities, source_city_id)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      identify_type(type),
      identify_serum_application(serum_application)
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
      "1" -> :type_canine
      "2" -> :type_feline
      "3" -> :type_chiroptera
      "4" -> :type_primate
      "5" -> :type_fox
      "6" -> :type_herbivore
      "7" -> :other_type
      _type -> :ignored_type
    end
  end

  defp identify_serum_application(serum_application) do
    case serum_application do
      "1" -> :applied_serum
      "2" -> :not_applied_serum
      _serum_application -> :ignored_serum_application
    end
  end
end
