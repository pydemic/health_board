defmodule HealthBoardWeb.DashboardLive.SectionData.ImmediateCompulsoryAnalyticControlDiagrams do
  @data_keys ~w[data_periods weekly_deaths weekly_morbidities weekly_populations]a
  @filter_keys ~w[morbidity_context]a

  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = section_data) do
    section_data
    |> Map.put(:data, Map.take(data, @data_keys))
    |> Map.put(:filters, Map.take(filters, @filter_keys))
  end
end
