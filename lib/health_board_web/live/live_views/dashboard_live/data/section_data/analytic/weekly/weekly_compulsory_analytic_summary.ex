defmodule HealthBoardWeb.DashboardLive.SectionData.WeeklyCompulsoryAnalyticSummary do
  @data_keys ~w[location yearly_deaths yearly_morbidities yearly_populations data_periods]a
  @filter_keys ~w[year morbidity_context]a

  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = section_data) do
    section_data
    |> Map.put(:data, Map.take(data, @data_keys))
    |> Map.put(:filters, Map.take(filters, @filter_keys))
  end
end
