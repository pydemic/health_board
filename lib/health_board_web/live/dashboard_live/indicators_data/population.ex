defmodule HealthBoardWeb.DashboardLive.IndicatorsData.Population do
  alias Phoenix.LiveView
  alias HealthBoard.Contexts.Demographic

  @context_filters [:age_group, :sex]

  @geo_filters [:country_id, :region_id, :state_id, :health_region_id, :city_id]

  @time_filters [:year]

  @allowed_filters @context_filters ++ @geo_filters ++ @time_filters

  @default_filters %{country_id: 76, year: 2020}

  @spec fetch(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def fetch(socket, filters) do
    filters
    |> extract_data()
    |> assign_to_socket(socket)
  end

  defp extract_data(filters) do
    filters = Map.merge(@default_filters, Map.take(filters, @allowed_filters))

    {module, geo_key, geo_value} = fetch_geo(Map.take(filters, @geo_filters))
    {function, context_value} = fetch_context(Map.take(filters, @context_filters))

    filters =
      filters
      |> Map.take(@time_filters)
      |> Map.put(geo_key, geo_value)
      |> Enum.to_list()

    params = if is_nil(context_value), do: [filters], else: [context_value, filters]

    apply(module, function, params)
  end

  defp fetch_geo(filters) do
    case filters do
      %{city_id: id} -> {Demographic.CitiesPopulation, :city_id, id}
      %{health_region_id: id} -> {Demographic.HealthRegionsPopulation, :health_region_id, id}
      %{state_id: id} -> {Demographic.StatesPopulation, :state_id, id}
      %{region_id: id} -> {Demographic.RegionsPopulation, :region_id, id}
      %{country_id: id} -> {Demographic.CountriesPopulation, :country_id, id}
    end
  end

  defp fetch_context(filters) do
    case filters do
      %{age_group: field} -> {:get_summary_by, field}
      %{sex: field} -> {:get_summary_by, field}
      _filters -> {:get_total_by, nil}
    end
  end

  defp assign_to_socket(data, socket) do
    LiveView.assign(socket, :population_data, data)
  end
end
