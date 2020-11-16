defmodule HealthBoardWeb.DashboardLive.IndicatorsData.ViolenceSexualDeathsPerSex do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.ViolenceSexualDeaths

  @labels %{male: "Masculino", female: "Feminino", ignored_sex: "Ignorado"}

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :violence)
    |> IndicatorsData.CommonData.fetch_year(2019)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:modifiers, :disease_context, &@indicator.get_disease_context/1)
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@indicator.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :cases, &@indicator.get_cases!/1)
    |> IndicatorsData.put(:data, :fields, [:male, :female, :ignored_sex])
    |> IndicatorsData.put(:extra, :labels, @labels)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :pie)
  end

  defp get_result(%{data: %{fields: fields}, extra: %{cases: cases}}) do
    Enum.map(fields, fn field ->
      %{
        field: field,
        value: Map.get(cases, field, 0)
      }
    end)
  end
end
