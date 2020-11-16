defmodule HealthBoardWeb.DashboardLive.IndicatorsData.PopulationMap do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.Population

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year()
    |> IndicatorsData.CommonData.fetch_locations()
    |> IndicatorsData.exec_and_put(:extra, :populations, &@indicator.list_populations/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &@indicator.get_fields/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.put(:extra, :value_type, :integer)
    |> IndicatorsData.exec_and_put(:data, :ranges, &IndicatorsData.EventData.create_ranges(&1, :quintile))
    |> IndicatorsData.emit_data(:map, :shape_color)
  end

  defp get_result(%{data: %{fields: [field]}, extra: %{populations: populations}}) do
    Enum.map(populations, &get_population_result(&1, field))
  end

  defp get_population_result(%{location_id: location_id} = population, field) do
    %{
      location_id: location_id,
      value: Map.get(population, field, 0)
    }
  end
end
