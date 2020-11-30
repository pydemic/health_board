defmodule HealthBoard.Scripts.Morbidities.Immediates.HumanRabiesConsolidator do
  alias HealthBoard.Scripts.Morbidities.Immediates.Consolidator

  @columns List.flatten([
             :cases,
             Consolidator.sex_age_groups(),
             Consolidator.races(),
             Consolidator.classifications(),
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
           ])

  @spec run :: :ok
  def run do
    Consolidator.run("human_rabies", &parse_line/1)
  end

  defp parse_line(line) do
    [date, source_city_id, resident_city_id, age_code, sex, race, classification, type, serum_application] = line

    fields = [
      :cases,
      Consolidator.identify_sex_age_group(sex, age_code),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      identify_type(type),
      identify_serum_application(serum_application)
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
