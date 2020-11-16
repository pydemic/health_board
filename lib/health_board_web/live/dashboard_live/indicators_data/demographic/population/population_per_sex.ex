defmodule HealthBoardWeb.DashboardLive.IndicatorsData.PopulationPerSex do
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
    |> IndicatorsData.put(:extra, :labels, %{male: "Masculino", female: "Feminino"})
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :pie)
  end

  defp get_result(%{data: %{fields: fields}, extra: %{population: population}}) do
    Enum.map(fields, fn field ->
      %{
        field: field,
        value: Map.get(population, field, 0)
      }
    end)
  end
end
