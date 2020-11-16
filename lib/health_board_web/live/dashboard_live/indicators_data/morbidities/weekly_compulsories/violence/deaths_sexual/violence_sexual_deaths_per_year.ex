defmodule HealthBoardWeb.DashboardLive.IndicatorsData.ViolenceSexualDeathsPerYear do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.ViolenceSexualDeaths

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :violence)
    |> IndicatorsData.CommonData.fetch_year_period()
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.put(:modifiers, :order_by, asc: :year)
    |> IndicatorsData.exec_and_put(:modifiers, :disease_context, &@indicator.get_disease_context/1)
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@indicator.get_location_context/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &@indicator.get_fields/1)
    |> IndicatorsData.exec_and_put(:extra, :cases, &@indicator.list_cases/1)
    |> IndicatorsData.exec_and_put(:extra, :labels, &get_labels/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :line)
  end

  defp get_labels(%{extra: %{year_period: [from, to]}}) do
    from
    |> Range.new(to)
    |> Enum.to_list()
  end

  defp get_result(%{data: %{fields: [field]}, extra: %{cases: cases, labels: labels}}) do
    Enum.map(labels, &get_label_result(&1, cases, field))
  end

  defp get_label_result(year, cases, field) do
    %{
      year: year,
      value: Enum.find_value(cases, 0, &if(&1.year == year, do: Map.get(&1, field, 0), else: nil))
    }
  end
end
