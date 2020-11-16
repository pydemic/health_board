defmodule HealthBoardWeb.DashboardLive.IndicatorsData.SexRatio do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.Population

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year()
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:extra, :population, &@indicator.get_population!/1)
    |> IndicatorsData.put(:data, :fields, [:male, :female])
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
  end

  defp get_result(%{extra: %{population: %{male: male, female: female}}}) do
    %{value: div(male * 100, female)}
  end
end
