defmodule HealthBoard.Scripts.Morbidities.Immediates.ChikungunyaConsolidator do
  alias HealthBoard.Scripts.Morbidities.Immediates.Consolidator

  @columns List.flatten([
             :cases,
             Consolidator.sex_age_groups(),
             Consolidator.races(),
             :confirmed,
             :discarded,
             :other_classification,
             :ignored_classification,
             :healed,
             :died_from_disease,
             :died_from_other_causes,
             :evolution_in_investigation,
             :ignored_evolution
           ])

  @spec run :: :ok
  def run do
    Consolidator.run("chikungunya", &parse_line/1)
  end

  defp parse_line([date, source_city_id, resident_city_id, age_code, sex, race, classification, evolution]) do
    fields = [
      :cases,
      Consolidator.identify_sex_age_group(sex, age_code),
      Consolidator.identify_race(race),
      identify_classification(classification),
      identify_evolution(evolution)
    ]

    {
      resident_city_id,
      source_city_id,
      date,
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
