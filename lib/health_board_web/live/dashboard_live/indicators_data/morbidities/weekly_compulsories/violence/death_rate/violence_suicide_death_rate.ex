defmodule HealthBoardWeb.DashboardLive.IndicatorsData.ViolenceSuicideDeathRate do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @population IndicatorsData.Population
  @cases IndicatorsData.ViolenceSuicideDeaths

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :violence)
    |> IndicatorsData.CommonData.fetch_year(2019)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:extra, :population, &@population.get_population!/1)
    |> IndicatorsData.exec_and_put(:modifiers, :disease_context, &@cases.get_disease_context/1)
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@cases.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :cases, &@cases.get_cases!/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
  end

  defp get_result(%{extra: %{population: %{total: population}, cases: %{cases: cases}}}) do
    %{
      cases: cases,
      population: population,
      value: if(population != 0, do: cases * 100_000 / population, else: 0.0)
    }
  end
end
