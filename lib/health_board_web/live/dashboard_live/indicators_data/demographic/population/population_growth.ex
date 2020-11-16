defmodule HealthBoardWeb.DashboardLive.IndicatorsData.PopulationGrowth do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.Population

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year_period()
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.put(:modifiers, :order_by, asc: :year)
    |> IndicatorsData.exec_and_put(:extra, :populations, &@indicator.list_populations/1)
    |> IndicatorsData.exec_and_put(:extra, :labels, &get_labels/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &@indicator.get_fields/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :line)
  end

  defp get_labels(%{extra: %{year_period: [from, to]}}) do
    from
    |> Range.new(to)
    |> Enum.to_list()
  end

  defp get_result(%{data: %{fields: [field]}, extra: %{populations: populations, labels: labels}}) do
    Enum.map(labels, &get_label_result(&1, populations, field))
  end

  defp get_label_result(year, populations, field) do
    %{
      year: year,
      value: Enum.find_value(populations, 0, &if(&1.year == year, do: Map.get(&1, field, 0), else: nil))
    }
  end
end
