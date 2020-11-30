defmodule HealthBoard.Scripts.Morbidities.WeeklyCompulsories.VisceralLeishmaniasisConsolidator do
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
    :hiv_coinfection,
    :no_hiv_coinfection,
    :ignored_hiv_coinfection,
    :new_entry,
    :recurrent_entry,
    :transferred_entry,
    :ignored_entry
  ]

  @spec run :: :ok
  def run do
    Consolidator.run("visceral_leishmaniasis", &parse_line/1)
  end

  defp parse_line(line) do
    [year, source_city_id, resident_city_id, age_code, sex, race, classification, hiv_coinfection, entry] = line

    year = String.to_integer(year)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      identify_hiv_coinfection(hiv_coinfection),
      identify_entry(entry)
    ]

    {
      resident_city_id,
      source_city_id,
      year,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_hiv_coinfection(hiv_coinfection) do
    case hiv_coinfection do
      "1" -> :hiv_coinfection
      "2" -> :no_hiv_coinfection
      _hiv_coinfection -> :ignored_hiv_coinfection
    end
  end

  defp identify_entry(entry) do
    case entry do
      "1" -> :new_entry
      "2" -> :recurrent_entry
      "3" -> :transferred_entry
      _entry -> :ignored_entry
    end
  end
end
