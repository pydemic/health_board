defmodule HealthBoardWeb.DashboardLive.IndicatorsData.BirthsPerChildSex do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.Births

  @labels %{child_male_sex: "Masculino", child_female_sex: "Feminino", ignored_child_sex: "Ignorado"}

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year(&@indicator.subtract_year_by_one/1)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@indicator.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :births, &@indicator.get_births!/1)
    |> IndicatorsData.put(:data, :fields, [:child_male_sex, :child_female_sex, :ignored_child_sex])
    |> IndicatorsData.put(:extra, :labels, @labels)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :pie)
  end

  defp get_result(%{data: %{fields: fields}, extra: %{births: births}}) do
    Enum.map(fields, fn field ->
      %{
        field: field,
        value: Map.get(births, field, 0)
      }
    end)
  end
end
