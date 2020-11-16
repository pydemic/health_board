defmodule HealthBoard.Scripts.Morbidities.Mortalities.YearlyConsolidator do
  require Logger
  alias HealthBoard.Scripts.Morbidities.Mortalities.Consolidator

  @dengue 1
  @chikungunya 2
  @zika 3
  @domestic_violence 4
  @sexual_violence 5
  @suicide 6

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
    :fetal,
    :non_fetal,
    :ignored_type,
    :investigated,
    :not_investigated,
    :ignored_investigation
  ]

  @spec run :: :ok
  def run do
    Consolidator.run("mortalities", &parse_line/2)
  end

  defp parse_line(line, cities) do
    [year, icd_10, source_city_id, resident_city_id, age_code, sex, race, type, investigation] = line

    year = String.to_integer(year)
    resident_city = Consolidator.find_city(cities, resident_city_id)
    source_city = Consolidator.find_city(cities, source_city_id)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      identify_type(type),
      identify_investigation(investigation)
    ]

    {
      identify_disease(icd_10),
      resident_city,
      source_city,
      year,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_type(type) do
    case type do
      "1" -> :fetal
      "2" -> :non_fetal
      _type -> :ignored_type
    end
  end

  defp identify_investigation(investigation) do
    case investigation do
      "1" -> :investigated
      "2" -> :not_investigated
      _investigation -> :ignored_investigation
    end
  end

  defp identify_disease(icd_10) do
    icd_10 = if String.length(icd_10) == 3, do: icd_10 <> "0", else: icd_10

    {code, digits} = String.split_at(icd_10, 1)
    digits = String.to_integer(digits)

    case code do
      "A" -> identify_group_a_disease(digits)
      "Y" -> identify_group_y_disease(digits)
      "X" -> identify_group_x_disease(digits)
      _code -> nil
    end
  rescue
    _error ->
      Logger.warn("Failed to identify disease with code: #{icd_10}")
      nil
  end

  defp identify_group_a_disease(digits) do
    cond do
      digits >= 900 and digits < 910 -> @dengue
      digits >= 920 and digits < 928 -> @chikungunya
      digits == 928 -> @zika
      true -> nil
    end
  end

  defp identify_group_y_disease(digits) do
    cond do
      digits >= 40 and digits < 50 -> @domestic_violence
      digits >= 50 and digits < 60 -> @sexual_violence
      true -> nil
    end
  end

  defp identify_group_x_disease(digits) do
    if digits >= 700 and digits < 850 do
      @suicide
    else
      nil
    end
  end
end
