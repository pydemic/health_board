defmodule HealthBoardWeb.DashboardLive.IndicatorsData.DengueIncidenceRatePerSex do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @population IndicatorsData.Population
  @cases IndicatorsData.DengueIncidence

  @labels %{male: "Masculino", female: "Feminino", ignored_sex: "Ignorado"}

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :dengue)
    |> IndicatorsData.CommonData.fetch_year(2018)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:extra, :population, &@population.get_population!/1)
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@cases.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :cases, &@cases.get_cases!/1)
    |> IndicatorsData.put(:data, :fields, [:male, :female, :ignored_sex])
    |> IndicatorsData.put(:extra, :labels, @labels)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :pie)
  end

  defp get_result(%{data: %{fields: fields}, extra: %{population: %{total: population}, cases: cases}}) do
    Enum.map(fields, fn field ->
      cases = Map.get(cases, field, 0.0)

      %{
        field: field,
        value: if(population != 0, do: cases * 100_000 / population, else: 0.0)
      }
    end)
  end
end
