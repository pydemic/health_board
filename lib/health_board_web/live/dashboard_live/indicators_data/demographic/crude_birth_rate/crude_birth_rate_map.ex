defmodule HealthBoardWeb.DashboardLive.IndicatorsData.CrudeBirthRateMap do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @births IndicatorsData.Births
  @population IndicatorsData.Population

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year()
    |> IndicatorsData.CommonData.fetch_locations()
    |> IndicatorsData.exec_and_put(:extra, :populations, &@population.list_populations/1)
    |> IndicatorsData.CommonData.fetch_year(&@births.subtract_year_by_one/1)
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@births.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :births, &@births.list_births/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.put(:extra, :value_type, :float)
    |> IndicatorsData.exec_and_put(:data, :ranges, &IndicatorsData.EventData.create_ranges(&1, :quintile))
    |> IndicatorsData.emit_data(:map, :shape_color)
  end

  defp get_result(%{extra: %{births: births, populations: populations}}) do
    Enum.map(births, &get_crude_birth_rate_result(&1, populations))
  end

  defp get_crude_birth_rate_result(%{births: births, location_id: location_id}, populations) do
    population = Enum.find_value(populations, 0, &if(&1.location_id == location_id, do: &1.total, else: nil))

    %{
      birth: births,
      location_id: location_id,
      population: population,
      value: if(population != 0, do: births * 1_000 / population, else: 0.0)
    }
  end
end
