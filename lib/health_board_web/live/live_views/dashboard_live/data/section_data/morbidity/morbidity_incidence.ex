defmodule HealthBoardWeb.DashboardLive.SectionData.MorbidityIncidence do
  @data_keys [
    :data_periods_per_context,
    :year_morbidity,
    :yearly_morbidity,
    :locations_morbidity,
    :weekly_morbidity,
    :locations_population,
    :yearly_population
  ]

  @filter_keys ~w[morbidity_context location year]a

  @spec fetch(map) :: map
  def fetch(%{data: data, filters: filters} = section_data) do
    section_data
    |> Map.put(:data, Map.take(data, @data_keys))
    |> Map.put(:filters, Map.take(filters, @filter_keys))
  end
end
