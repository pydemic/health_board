defmodule HealthBoardWeb.DashboardLive.IndicatorsData.PopulationPerAgeGroup do
  alias Phoenix.LiveView
  alias HealthBoard.Contexts.Demographic

  @context_filters [:age_groups]

  @geo_filters [:country_id, :region_id, :state_id, :health_region_id, :city_id]

  @time_filters [:year]

  @allowed_filters @context_filters ++ @geo_filters ++ @time_filters

  @default_age_groups [
    :age_0_4,
    :age_5_9,
    :age_10_14,
    :age_15_19,
    :age_20_24,
    :age_25_29,
    :age_30_34,
    :age_35_39,
    :age_40_44,
    :age_45_49,
    :age_50_54,
    :age_55_59,
    :age_60_64,
    :age_64_69,
    :age_70_74,
    :age_75_79,
    :age_80_or_more
  ]

  @default_filters %{country_id: 76, year: 2020, age_groups: @default_age_groups}

  @spec fetch(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def fetch(socket, filters) do
    filters
    |> extract_data()
    |> emit(socket)
    |> assign_to_socket()
  end

  defp extract_data(filters) do
    filters = Map.merge(@default_filters, Map.take(filters, @allowed_filters))

    fields = Map.get(filters, :age_groups, [])

    {module, geo_key, geo_value} = fetch_geo(Map.take(filters, @geo_filters))

    filters =
      filters
      |> Map.take(@time_filters)
      |> Map.put(geo_key, geo_value)
      |> Enum.to_list()

    %{data: apply(module, :get_by, [filters]), fields: fields}
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
    LiveView.assign(socket, :population_per_age_group_data, :emitted)
  end

  defp emit(map, socket) do
    LiveView.push_event(socket, "chart_data", build_js_data(map))
  end

  defp build_js_data(%{data: year_population, fields: fields}) do
    label = "População residente"
    labels = Enum.map(fields, &fields_labels/1)

    data = %{
      label: label,
      data: Enum.map(fields, &Map.get(year_population, &1, 0)),
      backgroundColor: "rgba(54, 162, 235, 0.2)",
      borderColor: "rgb(54, 162, 235)",
      borderWidth: 1
    }

    %{
      id: "population_per_age_group",
      data: %{
        type: "horizontalBar",
        data: %{
          labels: labels,
          datasets: [data]
        },
        options: %{
          legend: false,
          scales: %{
            xAxes: [
              %{
                scaleLabel: %{
                  display: true,
                  labelString: label
                }
              }
            ],
            yAxes: [
              %{
                ticks: %{
                  display: false
                }
              }
            ]
          }
        }
      }
    }
  end

  defp fields_labels(field) do
    case field do
      :age_0_4 -> "Entre 0 e 4 anos"
      :age_5_9 -> "Entre 5 e 9 anos"
      :age_10_14 -> "Entre 10 e 14 anos"
      :age_15_19 -> "Entre 15 e 19 anos"
      :age_20_24 -> "Entre 20 e 24 anos"
      :age_25_29 -> "Entre 25 e 29 anos"
      :age_30_34 -> "Entre 30 e 34 anos"
      :age_35_39 -> "Entre 35 e 39 anos"
      :age_40_44 -> "Entre 40 e 44 anos"
      :age_45_49 -> "Entre 45 e 49 anos"
      :age_50_54 -> "Entre 50 e 54 anos"
      :age_55_59 -> "Entre 55 e 59 anos"
      :age_60_64 -> "Entre 60 e 64 anos"
      :age_64_69 -> "Entre 65 e 69 anos"
      :age_70_74 -> "Entre 70 e 74 anos"
      :age_75_79 -> "Entre 75 e 79 anos"
      :age_80_or_more -> "80 anos ou mais"
    end
  end
end
