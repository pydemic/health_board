defmodule HealthBoard.Scripts.Morbidities.Immediates.PlagueConsolidator do
  alias HealthBoard.Scripts.Morbidities.Immediates.Consolidator

  @columns List.flatten([
             :cases,
             Consolidator.sex_age_groups(),
             Consolidator.races(),
             Consolidator.classifications(),
             Consolidator.evolutions(),
             :bubonic_form,
             :pneumonic_form,
             :septisemic_form,
             :other_form,
             :ignored_form,
             :low_gravity,
             :moderate_gravity,
             :high_gravity,
             :ignored_gravity
           ])

  @spec run :: :ok
  def run do
    Consolidator.run("plague", &parse_line/1)
  end

  defp parse_line(line) do
    [date, source_city_id, resident_city_id, age_code, sex, race, classification, evolution, form, gravity] = line

    fields = [
      :cases,
      Consolidator.identify_sex_age_group(sex, age_code),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      Consolidator.identify_evolution(evolution),
      identify_form(form),
      identify_gravity(gravity)
    ]

    {
      resident_city_id,
      source_city_id,
      date,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_form(form) do
    case form do
      "1" -> :bubonic_form
      "2" -> :pneumonic_form
      "3" -> :septisemic_form
      "4" -> :other_form
      _form -> :ignored_form
    end
  end

  defp identify_gravity(gravity) do
    case gravity do
      "1" -> :low_gravity
      "2" -> :moderate_gravity
      "3" -> :high_gravity
      _gravity -> :ignored_gravity
    end
  end
end
