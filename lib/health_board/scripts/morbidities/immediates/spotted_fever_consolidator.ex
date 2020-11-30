defmodule HealthBoard.Scripts.Morbidities.Immediates.SpottedFeverConsolidator do
  alias HealthBoard.Scripts.Morbidities.Immediates.Consolidator

  @columns List.flatten([
             :cases,
             Consolidator.sex_age_groups(),
             Consolidator.races(),
             Consolidator.classifications(),
             Consolidator.evolutions()
           ])

  @spec run :: :ok
  def run do
    Consolidator.run("spotted_fever", &parse_line/1)
  end

  defp parse_line([date, source_city_id, resident_city_id, age_code, sex, race, classification, evolution]) do
    fields = [
      :cases,
      Consolidator.identify_sex_age_group(sex, age_code),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      Consolidator.identify_evolution(evolution)
    ]

    {
      resident_city_id,
      source_city_id,
      date,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end
end
