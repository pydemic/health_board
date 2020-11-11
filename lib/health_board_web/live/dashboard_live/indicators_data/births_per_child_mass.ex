defmodule HealthBoardWeb.DashboardLive.IndicatorsData.BirthsPerChildMass do
  alias Phoenix.LiveView
  alias HealthBoard.Contexts.Demographic

  @context_filters [:child_masses]

  @geo_filters [:country_id, :region_id, :state_id, :health_region_id, :city_id]

  @group_filters [:birth_origin]

  @time_filters [:year]

  @allowed_filters @context_filters ++ @geo_filters ++ @group_filters ++ @time_filters

  @default_child_masses [
    :child_mass_500_or_less,
    :child_mass_500_999,
    :child_mass_1000_1499,
    :child_mass_1500_2499,
    :child_mass_2500_2999,
    :child_mass_3000_3999,
    :child_mass_4000_or_more,
    :ignored_child_mass
  ]

  @default_filters %{birth_origin: :resident, country_id: 76, year: 2019, child_masses: @default_child_masses}

  @spec fetch(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def fetch(socket, filters) do
    filters
    |> extract_data()
    |> emit(socket)
    |> assign_to_socket()
  end

  defp extract_data(filters) do
    filters = Map.merge(@default_filters, Map.take(filters, @allowed_filters))

    fields = Map.get(filters, :child_masses, [])

    {module, query_filters} = fetch_module(Map.drop(filters, @context_filters))

    %{data: apply(module, :get_by, [query_filters]), fields: fields}
  end

  defp fetch_module(filters) do
    case filters do
      %{date: date} -> fetch_daily_module(filters, date: date)
      %{week: week} -> fetch_daily_module(filters, week: week)
      %{year: period} -> fetch_yearly_module(filters, year: period)
    end
  end

  defp fetch_daily_module(filters, query_filters) do
    case filters do
      %{city_id: id, birth_origin: :resident} ->
        {Demographic.CitiesResidentBirths, Keyword.put(query_filters, :city_id, id)}

      %{city_id: id} ->
        {Demographic.CitiesSourceBirths, Keyword.put(query_filters, :city_id, id)}

      %{health_region_id: id, birth_origin: :resident} ->
        {Demographic.HealthRegionsResidentBirths, Keyword.put(query_filters, :health_region_id, id)}

      %{health_region_id: id} ->
        {Demographic.HealthRegionsSourceBirths, Keyword.put(query_filters, :health_region_id, id)}

      %{state_id: id, birth_origin: :resident} ->
        {Demographic.StatesResidentBirths, Keyword.put(query_filters, :state_id, id)}

      %{state_id: id} ->
        {Demographic.StatesSourceBirths, Keyword.put(query_filters, :state_id, id)}

      %{region_id: id, birth_origin: :resident} ->
        {Demographic.RegionsResidentBirths, Keyword.put(query_filters, :region_id, id)}

      %{region_id: id} ->
        {Demographic.RegionsSourceBirths, Keyword.put(query_filters, :region_id, id)}

      %{country_id: id, birth_origin: :resident} ->
        {Demographic.CountriesResidentBirths, Keyword.put(query_filters, :country_id, id)}

      %{country_id: id} ->
        {Demographic.CountriesSourceBirths, Keyword.put(query_filters, :country_id, id)}
    end
  end

  defp fetch_yearly_module(filters, query_filters) do
    case filters do
      %{city_id: id, birth_origin: :resident} ->
        {Demographic.CitiesResidentYearlyBirths, Keyword.put(query_filters, :city_id, id)}

      %{city_id: id} ->
        {Demographic.CitiesSourceYearlyBirths, Keyword.put(query_filters, :city_id, id)}

      %{health_region_id: id, birth_origin: :resident} ->
        {Demographic.HealthRegionsResidentYearlyBirths, Keyword.put(query_filters, :health_region_id, id)}

      %{health_region_id: id} ->
        {Demographic.HealthRegionsSourceYearlyBirths, Keyword.put(query_filters, :health_region_id, id)}

      %{state_id: id, birth_origin: :resident} ->
        {Demographic.StatesResidentYearlyBirths, Keyword.put(query_filters, :state_id, id)}

      %{state_id: id} ->
        {Demographic.StatesSourceYearlyBirths, Keyword.put(query_filters, :state_id, id)}

      %{region_id: id, birth_origin: :resident} ->
        {Demographic.RegionsResidentYearlyBirths, Keyword.put(query_filters, :region_id, id)}

      %{region_id: id} ->
        {Demographic.RegionsSourceYearlyBirths, Keyword.put(query_filters, :region_id, id)}

      %{country_id: id, birth_origin: :resident} ->
        {Demographic.CountriesResidentYearlyBirths, Keyword.put(query_filters, :country_id, id)}

      %{country_id: id} ->
        {Demographic.CountriesSourceYearlyBirths, Keyword.put(query_filters, :country_id, id)}
    end
  end

  defp assign_to_socket(socket) do
    LiveView.assign(socket, :births_per_child_mass_data, :emitted)
  end

  defp emit(map, socket) do
    LiveView.push_event(socket, "chart_data", build_js_data(map))
  end

  defp build_js_data(%{data: births_per_year, fields: fields}) do
    %{
      id: "births_per_child_mass",
      data: %{
        type: "pie",
        data: %{
          labels: Enum.map(fields, &field_label/1),
          datasets: [
            %{
              data: Enum.map(fields, &Map.get(births_per_year, &1, 0)),
              backgroundColor: Enum.map(fields, &get_field_color/1)
            }
          ]
        },
        options: %{
          legend: false
        }
      }
    }
  end

  defp field_label(field) do
    case field do
      :child_mass_500_or_less -> "Menos de 500g"
      :child_mass_500_999 -> "Entre 500g e 999g"
      :child_mass_1000_1499 -> "Entre 1000g e 1499g"
      :child_mass_1500_2499 -> "Entre 1500g e 2499g"
      :child_mass_2500_2999 -> "Entre 2500g e 2999g"
      :child_mass_3000_3999 -> "Entre 3000g e 3999g"
      :child_mass_4000_or_more -> "Mais de 4000g"
      :ignored_child_mass -> "Ignorado"
    end
  end

  defp get_field_color(field) do
    case field do
      :child_mass_500_or_less -> "#ffa600"
      :child_mass_500_999 -> "#ff764a"
      :child_mass_1000_1499 -> "#ef5675"
      :child_mass_1500_2499 -> "#bc5090"
      :child_mass_2500_2999 -> "#7a5195"
      :child_mass_3000_3999 -> "#374c80"
      :child_mass_4000_or_more -> "#003f5c"
      :ignored_child_mass -> "#333333"
    end
  end
end
