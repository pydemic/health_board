defmodule HealthBoard.Scripts.Morbidities.Immediates.MalariaFromExtraAmazonConsolidator do
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
    :exam_result_negative,
    :exam_result_f,
    :exam_result_f_plus_fg,
    :exam_result_v,
    :exam_result_f_plus_v,
    :exam_result_v_plus_fg,
    :exam_result_fg,
    :ignored_exam_result
  ]

  @spec run :: :ok
  def run do
    Consolidator.run("malaria_from_extra_amazon", &parse_line/2)
  end

  defp parse_line(line, cities) do
    [date, source_city_id, resident_city_id, age_code, sex, race, classification, exam_result] = line

    %{year: year} = Date.from_iso8601!(date)

    resident_city = Consolidator.find_city(cities, resident_city_id)
    source_city = Consolidator.find_city(cities, source_city_id)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      Consolidator.identify_classification(classification),
      identify_exam_result(exam_result)
    ]

    {
      resident_city,
      source_city,
      year,
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
