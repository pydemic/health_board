defmodule HealthBoardWeb.DashboardLive.IndicatorsData.BirthsPerChildSex do
  alias Phoenix.LiveView
  alias HealthBoard.Contexts.Demographic

  @geo_filters [:country_id, :region_id, :state_id, :health_region_id, :city_id]

  @group_filters [:birth_origin]

  @time_filters [:year]

  @allowed_filters @geo_filters ++ @group_filters ++ @time_filters

  @default_filters %{birth_origin: :resident, country_id: 76, year: 2019}

  @spec fetch(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def fetch(socket, filters) do
    filters
    |> extract_data()
    |> emit(socket)
    |> assign_to_socket()
  end

  defp extract_data(filters) do
    filters = Map.merge(@default_filters, Map.take(filters, @allowed_filters))

    {module, query_filters} = fetch_module(filters)

    apply(module, :get_by, [query_filters])
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
    LiveView.assign(socket, :births_per_child_sex_data, :emitted)
  end

  defp emit(map, socket) do
    LiveView.push_event(socket, "chart_data", build_js_data(map))
  end

  defp build_js_data(%{child_male_sex: male, child_female_sex: female, ignored_child_sex: ignored}) do
    %{
      id: "births_per_child_sex",
      data: %{
        type: "pie",
        data: %{
          labels: ["Masculino", "Feminino", "Ignorado"],
          datasets: [
            %{
              data: [male, female, ignored],
              backgroundColor: ["rgb(54,162,235)", "rgb(165,54,54)", "#333333"]
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
