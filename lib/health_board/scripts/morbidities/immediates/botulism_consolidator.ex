defmodule HealthBoard.Scripts.Morbidities.Immediates.BotulismConsolidator do
  alias HealthBoard.Scripts.Morbidities.Immediates.Consolidator

  @columns List.flatten([
             :cases,
             Consolidator.sex_age_groups(),
             Consolidator.races(),
             Consolidator.classifications(),
             Consolidator.evolutions(),
             :type_food,
             :type_intestinal,
             :type_wound,
             :other_type,
             :ignored_type
           ])

  @spec run :: :ok
  def run do
    Consolidator.run("botulism", &parse_line/1)
  end

  defp parse_line(line) do
    [date, source_city_id, resident_city_id, age_code, sex, race, classification, evolution, type] = line

    fields = [
      :cases,
      Consolidator.identify_sex_age_group(sex, age_code),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      Consolidator.identify_evolution(evolution),
      identify_type(type)
    ]

    {
      resident_city_id,
      source_city_id,
      date,
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
