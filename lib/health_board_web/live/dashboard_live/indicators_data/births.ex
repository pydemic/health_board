defmodule HealthBoardWeb.DashboardLive.IndicatorsData.Births do
  alias Phoenix.LiveView
  alias HealthBoard.Contexts.Demographic

  @context_filters [
    :child_mass,
    :child_sex,
    :delivery,
    :gestation_duration,
    :birth_location,
    :mother_age,
    :prenatal_consultation
  ]

  @geo_filters [:country_id, :region_id, :state_id, :health_region_id, :city_id]

  @group_filters [:birth_origin]

  @time_filters [:year, :week, :date]

  @allowed_filters @context_filters ++ @geo_filters ++ @group_filters ++ @time_filters

  @default_filters %{birth_origin: :resident, country_id: 76, year: 2019}

  @spec fetch(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def fetch(socket, filters) do
    filters
    |> extract_data()
    |> assign_to_socket(socket)
  end

  defp extract_data(filters) do
    filters = Map.merge(@default_filters, Map.take(filters, @allowed_filters))

    {module, query_filters} = fetch_module(Map.drop(filters, @context_filters))
    {function, context_value} = fetch_context(Map.take(filters, @context_filters))

    params = if is_nil(context_value), do: [query_filters], else: [context_value, query_filters]

    apply(module, function, params)
  end

  defp fetch_module(filters) do
    case filters do
      %{date: date} -> fetch_daily_module(filters, date: date)
      %{week: week} -> fetch_daily_module(filters, week: week)
      %{year: year} -> fetch_yearly_module(filters, year: year)
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

  defp fetch_context(filters) do
    case filters do
      %{child_mass: field} -> {:get_summary_by, field}
      %{child_sex: field} -> {:get_summary_by, field}
      %{delivery: field} -> {:get_summary_by, field}
      %{gestation_duration: field} -> {:get_summary_by, field}
      %{birth_location: field} -> {:get_summary_by, field}
      %{mother_age: field} -> {:get_summary_by, field}
      %{prenatal_consultation: field} -> {:get_summary_by, field}
      _filters -> {:get_total_by, nil}
    end
  end

  defp assign_to_socket(data, socket) do
    LiveView.assign(socket, :births_data, data)
  end
end
