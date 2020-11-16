defmodule HealthBoardWeb.DashboardLive.IndicatorsData.DengueIncidenceRatePerAgeGroup do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @population IndicatorsData.Population
  @cases IndicatorsData.DengueIncidence

  @filter_key "person_age_groups"

  @default_fields [
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
    :age_80_or_more
  ]

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :dengue)
    |> IndicatorsData.CommonData.fetch_year(2018)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:extra, :population, &@population.get_population!/1)
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@cases.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :cases, &@cases.get_cases!/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &Map.get(&1.filters, @filter_key, @default_fields))
    |> IndicatorsData.exec_and_put(:extra, :labels, &get_labels/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :horizontal_bar)
  end

  defp get_labels(%{data: %{fields: fields}}) do
    for field <- fields, into: %{}, do: get_label(field)
  end

  defp get_label(field) do
    case field do
      :age_0_4 -> {field, "Entre 0 e 4 anos"}
      :age_5_9 -> {field, "Entre 5 e 9 anos"}
      :age_10_14 -> {field, "Entre 10 e 14 anos"}
      :age_15_19 -> {field, "Entre 15 e 19 anos"}
      :age_20_24 -> {field, "Entre 20 e 24 anos"}
      :age_25_29 -> {field, "Entre 25 e 29 anos"}
      :age_30_34 -> {field, "Entre 30 e 34 anos"}
      :age_35_39 -> {field, "Entre 35 e 39 anos"}
      :age_40_44 -> {field, "Entre 40 e 44 anos"}
      :age_45_49 -> {field, "Entre 45 e 49 anos"}
      :age_50_54 -> {field, "Entre 50 e 54 anos"}
      :age_55_59 -> {field, "Entre 55 e 59 anos"}
      :age_60_64 -> {field, "Entre 60 e 64 anos"}
      :age_64_69 -> {field, "Entre 65 e 69 anos"}
      :age_70_74 -> {field, "Entre 70 e 74 anos"}
      :age_75_79 -> {field, "Entre 75 e 79 anos"}
      :age_80_or_more -> {field, "80 anos ou mais"}
    end
  end

  defp get_result(%{data: %{fields: fields}, extra: %{population: %{total: population}, cases: cases}}) do
    Enum.map(fields, fn field ->
      cases = Map.get(cases, field, 0.0)

      %{
        field: field,
        value: if(population != 0, do: cases * 100_000 / population, else: 0.0)
      }
    end)
  end
end
