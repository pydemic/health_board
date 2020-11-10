defmodule HealthBoardWeb.DashboardLive.IndicatorsData.PopulationGrowth do
  alias Phoenix.LiveView
  alias HealthBoard.Contexts.Demographic

  @context_filters [:age_group, :sex]

  @geo_filters [:country_id, :region_id, :state_id, :health_region_id, :city_id]

  @time_filters [:year_period]

  @allowed_filters @context_filters ++ @geo_filters ++ @time_filters

  @default_filters %{country_id: 76, year_period: [2000, 2020]}

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
      %{age_group: field} -> {:list_summary_by, field}
      %{sex: field} -> {:list_summary_by, field}
      _filters -> {:list_total_by, nil}
    end
  end

  defp assign_to_socket(socket) do
    LiveView.assign(socket, :population_growth_data, :emitted)
  end

  defp emit(data, socket) do
    LiveView.push_event(socket, "chart_data", build_js_data(data, socket.assigns))
  end

  defp build_js_data(yearly_population, assigns) do
    [from, to] =
      assigns
      |> Map.get(:filters, %{})
      |> Map.get(:year_period, [2000, 2020])

    data =
      from
      |> Range.new(to)
      |> Enum.to_list()
      |> Enum.zip(yearly_population)
      |> Enum.map(fn {year, data} ->
        %{
          label: "#{year}",
          data: [data],
          backgroundColor: "rgba(54, 162, 235, 0.2)",
          borderColor: "rgb(54, 162, 235)",
          borderWidth: 1
        }
      end)

    %{
      id: "population_growth",
      data: %{
        type: "bar",
        data: %{
          labels: ["População residente"],
          datasets: data
        },
        options: %{
          legend: false
        }
      }
    }
  end
end
