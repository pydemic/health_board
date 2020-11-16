defmodule HealthBoardWeb.DashboardLive.IndicatorsData.BirthsPerDelivery do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.Births

  @filter_key "births_deliveries"

  @default_fields [
    :vaginal_delivery,
    :cesarean_delivery,
    :other_delivery,
    :ignored_delivery
  ]

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year(&@indicator.subtract_year_by_one/1)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@indicator.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :births, &@indicator.get_births!/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &Map.get(&1.filters, @filter_key, @default_fields))
    |> IndicatorsData.exec_and_put(:extra, :labels, &get_labels/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :vertical_bar)
  end

  defp get_labels(%{data: %{fields: fields}}) do
    for field <- fields, into: %{}, do: get_label(field)
  end

  defp get_label(field) do
    case field do
      :vaginal_delivery -> {field, "Vaginal"}
      :cesarean_delivery -> {field, "Cesáreo"}
      :other_delivery -> {field, "Outros"}
      :ignored_delivery -> {field, "Ignorado"}
    end
  end

  defp get_result(%{data: %{fields: fields}, extra: %{births: births}}) do
    Enum.map(fields, fn field ->
      %{
        field: field,
        value: Map.get(births, field, 0)
      }
    end)
  end
end
