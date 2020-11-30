defmodule HealthBoard.Scripts.Morbidities.Immediates.YellowFeverConsolidator do
  alias HealthBoard.Scripts.Morbidities.Immediates.Consolidator

  @columns List.flatten([
             :cases,
             Consolidator.sex_age_groups(),
             Consolidator.races(),
             :confirmed_wild,
             :confirmed_urban,
             :discarded,
             :ignored_classification,
             Consolidator.evolutions(),
             :applied_vaccine,
             :not_applied_vaccine,
             :ignored_vaccine_application
           ])

  @spec run :: :ok
  def run do
    Consolidator.run("yellow_fever", &parse_line/1)
  end

  defp parse_line(line) do
    [date, source_city_id, resident_city_id, age_code, sex, race, classification, evolution, vaccine_application] = line

    fields = [
      :cases,
      Consolidator.identify_sex_age_group(sex, age_code),
      Consolidator.identify_race(race),
      identify_classification(classification),
      Consolidator.identify_evolution(evolution),
      identify_vaccine_application(vaccine_application)
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
      "1" -> :confirmed_wild
      "2" -> :confirmed_urban
      "3" -> :discarded
      _classification -> :ignored_classification
    end
  end

  defp identify_vaccine_application(vaccine_application) do
    case vaccine_application do
      "1" -> :applied_vaccine
      "2" -> :not_applied_vaccine
      _vaccine_application -> :ignored_vaccine_application
    end
  end
end
