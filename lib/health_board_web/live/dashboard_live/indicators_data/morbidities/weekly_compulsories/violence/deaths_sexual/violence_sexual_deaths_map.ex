defmodule HealthBoardWeb.DashboardLive.IndicatorsData.ViolenceSexualDeathsMap do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.ViolenceSexualDeaths

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :violence)
    |> IndicatorsData.CommonData.fetch_year(2019)
    |> IndicatorsData.CommonData.fetch_locations()
    |> IndicatorsData.exec_and_put(:modifiers, :disease_context, &@indicator.get_disease_context/1)
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@indicator.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :cases, &@indicator.list_cases/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &@indicator.get_fields/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.put(:extra, :value_type, :integer)
    |> IndicatorsData.exec_and_put(:data, :ranges, &IndicatorsData.EventData.create_ranges(&1, :quintile))
    |> IndicatorsData.emit_data(:map, :shape_color)
  end

  defp get_result(%{data: %{fields: [field]}, extra: %{cases: cases}}) do
    Enum.map(cases, &get_cases_result(&1, field))
  end

  defp get_cases_result(%{location_id: location_id} = cases, field) do
    %{
      location_id: location_id,
      value: Map.get(cases, field, 0)
    }
  end
end
