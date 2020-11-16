defmodule HealthBoardWeb.DashboardLive.IndicatorsData.DengueDeathsPerRace do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.DengueDeaths

  @filter_key "person_races"

  @default_fields [
    :race_caucasian,
    :race_african,
    :race_asian,
    :race_brown,
    :race_native,
    :ignored_race
  ]

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :dengue)
    |> IndicatorsData.CommonData.fetch_year(2019)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:modifiers, :disease_context, &@indicator.get_disease_context/1)
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@indicator.get_location_context/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &Map.get(&1.filters, @filter_key, @default_fields))
    |> IndicatorsData.exec_and_put(:extra, :cases, &@indicator.get_cases!/1)
    |> IndicatorsData.exec_and_put(:extra, :labels, &get_labels/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :horizontal_bar)
  end

  defp get_labels(%{data: %{fields: fields}}) do
    for field <- fields, into: %{}, do: get_label(field)
  end

  defp get_label(field) do
    case field do
      :race_caucasian -> {field, "Branco"}
      :race_african -> {field, "Preto"}
      :race_asian -> {field, "Amarelo"}
      :race_brown -> {field, "Pardo"}
      :race_native -> {field, "Indígena"}
      :ignored_race -> {field, "Ignorado"}
    end
  end

  defp get_result(%{data: %{fields: fields}, extra: %{cases: cases}}) do
    Enum.map(fields, fn field ->
      %{
        field: field,
        value: Map.get(cases, field, 0)
      }
    end)
  end
end
