defmodule HealthBoardWeb.DashboardLive.SectionData.ImmediateCompulsoryAnalyticSummary do
  @data_keys ~w[year data_periods_per_context yearly_deaths_per_context yearly_morbidities_per_context]a
  @filter_keys ~w[location year]a

  @spec fetch(map) :: map
  def fetch(%{data: data, filters: filters} = section_data) do
    section_data
    |> Map.put(:data, Map.take(data, @data_keys))
    |> Map.put(:filters, Map.take(filters, @filter_keys))
  end
end
