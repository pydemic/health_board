defmodule HealthBoard.Scripts.Morbidities.WeeklyCompulsories.TuberculosisConsolidator do
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
    :free_condition,
    :non_free_condition,
    :ignored_free_condition,
    :homeless_condition,
    :non_homeless_condition,
    :ignored_homeless_condition,
    :health_professional_condition,
    :non_health_professional_condition,
    :ignored_health_professional_condition,
    :immigrant_condition,
    :non_immigrant_condition,
    :ignored_immigrant_condition,
    :positive_hiv_condition,
    :negative_hiv_condition,
    :to_be_defined_hiv_condition,
    :ignored_hiv_condition,
    :aids_condition,
    :non_aids_condition,
    :ignored_aids_condition,
    :alcohol_condition,
    :non_alcohol_condition,
    :ignored_alcohol_condition,
    :diabetes_condition,
    :non_diabetes_condition,
    :ignored_diabetes_condition,
    :mental_condition,
    :non_mental_condition,
    :ignored_mental_condition,
    :illicit_drugs_condition,
    :non_illicit_drugs_condition,
    :ignored_illicit_drugs_condition,
    :smoking_condition,
    :non_smoking_condition,
    :ignored_smoking_condition,
    :other_conditions,
    :no_other_conditions,
    :ignored_other_conditions
  ]

  @spec run :: :ok
  def run do
    Consolidator.run("tuberculosis", &parse_line/2)
  end

  defp parse_line(line, cities) do
    [
      year,
      source_city_id,
      resident_city_id,
      age_code,
      sex,
      race,
      free_condition,
      homeless_condition,
      health_professional_condition,
      immigrant_condition,
      hiv_condition,
      aids_condition,
      alcohol_condition,
      diabetes_condition,
      mental_condition,
      illicit_drugs_condition,
      smoking_condition,
      other_conditions
    ] = line

    year = String.to_integer(year)
    resident_city = Consolidator.find_city(cities, resident_city_id)
    source_city = Consolidator.find_city(cities, source_city_id)

    fields = [
      :cases,
      Consolidator.identify_age_group(age_code),
      Consolidator.identify_sex(sex),
      Consolidator.identify_race(race),
      identify_condition(free_condition, :free_condition, :non_free_condition, :ignored_free_condition),
      identify_condition(homeless_condition, :homeless_condition, :non_homeless_condition, :ignored_homeless_condition),
      identify_condition(
        health_professional_condition,
        :health_professional_condition,
        :non_health_professional_condition,
        :ignored_health_professional_condition
      ),
      identify_condition(
        immigrant_condition,
        :immigrant_condition,
        :non_immigrant_condition,
        :ignored_immigrant_condition
      ),
      identify_hiv_condition(hiv_condition),
      identify_condition(aids_condition, :aids_condition, :non_aids_condition, :ignored_aids_condition),
      identify_condition(alcohol_condition, :alcohol_condition, :non_alcohol_condition, :ignored_alcohol_condition),
      identify_condition(diabetes_condition, :diabetes_condition, :non_diabetes_condition, :ignored_diabetes_condition),
      identify_condition(mental_condition, :mental_condition, :non_mental_condition, :ignored_mental_condition),
      identify_condition(
        illicit_drugs_condition,
        :illicit_drugs_condition,
        :non_illicit_drugs_condition,
        :ignored_illicit_drugs_condition
      ),
      identify_condition(smoking_condition, :smoking_condition, :non_smoking_condition, :ignored_smoking_condition),
      identify_condition(other_conditions, :other_conditions, :no_other_conditions, :ignored_other_conditions)
    ]

    {
      resident_city,
      source_city,
      year,
      Enum.map(@columns, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_condition(condition, yes, no, ignored) do
    case condition do
      "1" -> yes
      "2" -> no
      _condition -> ignored
    end
  end

  defp identify_hiv_condition(hiv_condition) do
    case hiv_condition do
      "1" -> :positive_hiv_condition
      "2" -> :negative_hiv_condition
      "3" -> :to_be_defined_hiv_condition
      _hiv_condition -> :ignored_hiv_condition
    end
  end
end
