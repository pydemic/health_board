defmodule HealthBoardWeb.DashboardLive.IndicatorsData.CrudeBirthRate do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @births IndicatorsData.Births
  @population IndicatorsData.Population

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year()
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:extra, :population, &@population.get_population!/1)
    |> IndicatorsData.CommonData.fetch_year(&@births.subtract_year_by_one/1)
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@births.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :births, &@births.get_births!/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
  end

  defp get_result(%{extra: %{population: %{total: population}, births: %{births: births}}}) do
    %{
      births: births,
      population: population,
      value: if(population != 0, do: births * 1_000 / population, else: 0.0)
    }
  end
end
