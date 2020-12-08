defmodule HealthBoardWeb.DashboardLive.SectionData.WeeklyCompulsoryAnalyticHistory do
  @data_keys ~w[from_year to_year yearly_deaths_per_context yearly_morbidities_per_context yearly_population]a
  @filter_keys ~w[from_year to_year location]a

  @spec fetch(map) :: map
  def fetch(%{data: data, filters: filters} = section_data) do
    section_data
    |> Map.put(:data, Map.take(data, @data_keys))
    |> Map.put(:filters, Map.take(filters, @filter_keys))
  end
end
