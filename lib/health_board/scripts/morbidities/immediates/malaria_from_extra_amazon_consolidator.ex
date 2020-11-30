defmodule HealthBoard.Scripts.Morbidities.Immediates.MalariaFromExtraAmazonConsolidator do
  alias HealthBoard.Scripts.Morbidities.Immediates.Consolidator

  @columns List.flatten([
             :cases,
             Consolidator.sex_age_groups(),
             Consolidator.races(),
             Consolidator.classifications(),
             :exam_result_negative,
             :exam_result_f,
             :exam_result_f_plus_fg,
             :exam_result_v,
             :exam_result_f_plus_v,
             :exam_result_v_plus_fg,
             :exam_result_fg,
             :ignored_exam_result
           ])

  @spec run :: :ok
  def run do
    Consolidator.run("malaria_from_extra_amazon", &parse_line/1)
  end

  defp parse_line(line) do
    [date, source_city_id, resident_city_id, age_code, sex, race, classification, exam_result] = line

    fields = [
      :cases,
      Consolidator.identify_sex_age_group(sex, age_code),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      identify_exam_result(exam_result)
    ]

    {
      resident_city_id,
      source_city_id,
      date,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_exam_result(exam_result) do
    case exam_result do
      "1" -> :exam_result_negative
      "2" -> :exam_result_f
      "3" -> :exam_result_f_plus_fg
      "4" -> :exam_result_v
      "5" -> :exam_result_f_plus_v
      "6" -> :exam_result_v_plus_fg
      "7" -> :exam_result_fg
      _exam_result -> :ignored_exam_result
    end
  end
end
