defmodule HealthBoardWeb.DashboardLive.SectionData.ImmediateCompulsoryAnalyticRegion do
  @data_keys ~w[locations locations_contexts_deaths locations_contexts_morbidities locations_population]a
  @filter_keys ~w[locations year]a

  @spec fetch(map) :: map
  def fetch(%{data: data, filters: filters} = section_data) do
    section_data
    |> Map.put(:data, Map.take(data, @data_keys))
    |> Map.put(:filters, Map.take(filters, @filter_keys))
  end
end
