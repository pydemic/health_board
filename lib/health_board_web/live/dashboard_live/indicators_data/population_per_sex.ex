defmodule HealthBoardWeb.DashboardLive.IndicatorsData.PopulationPerSex do
  alias Phoenix.LiveView
  alias HealthBoard.Contexts.Demographic

  @geo_filters [:country_id, :region_id, :state_id, :health_region_id, :city_id]

  @time_filters [:year]

  @allowed_filters @geo_filters ++ @time_filters

  @default_filters %{country_id: 76, year: 2020}

  @spec fetch(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def fetch(socket, filters) do
    filters
    |> extract_data()
    |> emit(socket)
    |> assign_to_socket()
  end

  defp extract_data(filters) do
    filters = Map.merge(@default_filters, Map.take(filters, @allowed_filters))

    {module, geo_key, geo_value} = fetch_geo(Map.take(filters, @geo_filters))

    filters =
      filters
      |> Map.take(@time_filters)
      |> Map.put(geo_key, geo_value)
      |> Enum.to_list()

    apply(module, :get_by, [filters])
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

  defp assign_to_socket(socket) do
    LiveView.assign(socket, :population_per_sex_data, :emitted)
  end

  defp emit(data, socket) do
    LiveView.push_event(socket, "chart_data", build_js_data(data))
  end

  defp build_js_data(%{male: male, female: female}) do
    %{
      id: "population_per_sex",
      data: %{
        type: "pie",
        data: %{
          labels: ["Masculino", "Feminino"],
          datasets: [
            %{
              data: [male, female],
              backgroundColor: ["rgb(54,162,235)", "rgb(165,54,54)"]
            }
          ]
        },
        options: %{
          legend: false
        }
      }
    }
  end
end
