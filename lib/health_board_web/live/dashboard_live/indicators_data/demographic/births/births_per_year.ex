defmodule HealthBoardWeb.DashboardLive.IndicatorsData.BirthsPerYear do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.Births

  @default_birth_year_period [2000, 2018]

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year_period(&subtract_years_by_one/1)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@indicator.get_location_context/1)
    |> IndicatorsData.put(:modifiers, :order_by, asc: :year)
    |> IndicatorsData.exec_and_put(:extra, :births, &@indicator.list_births/1)
    |> IndicatorsData.exec_and_put(:extra, :labels, &get_labels/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &@indicator.get_fields/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :line)
  end

  defp subtract_years_by_one(year_period) do
    if is_list(year_period) do
      Enum.map(year_period, &@indicator.subtract_year_by_one/1)
    else
      @default_birth_year_period
    end
  end

  defp get_labels(%{extra: %{year_period: [from, to]}}) do
    from
    |> Range.new(to)
    |> Enum.to_list()
  end

  defp get_result(%{data: %{fields: [field]}, extra: %{births: births, labels: labels}}) do
    Enum.map(labels, &get_label_result(&1, births, field))
  end

  defp get_label_result(year, births, field) do
    %{
      year: year,
      value: Enum.find_value(births, 0, &if(&1.year == year, do: Map.get(&1, field, 0), else: nil))
    }
  end
end
