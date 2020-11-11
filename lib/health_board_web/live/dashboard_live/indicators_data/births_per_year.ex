defmodule HealthBoardWeb.DashboardLive.IndicatorsData.BirthsPerYear do
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

  @time_filters [:year_period, :week_period, :date_period]

  @allowed_filters @context_filters ++ @geo_filters ++ @group_filters ++ @time_filters

  @default_filters %{birth_origin: :resident, country_id: 76, year_period: [2000, 2019]}

  @spec fetch(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def fetch(socket, filters) do
    filters
    |> extract_data()
    |> emit(socket)
    |> assign_to_socket()
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
      %{date_period: period} -> fetch_daily_module(filters, date_period: period)
      %{week_period: period} -> fetch_daily_module(filters, week_period: period)
      %{year_period: period} -> fetch_yearly_module(filters, year_period: period)
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
      %{child_mass: field} -> {:list_summary_by, field}
      %{child_sex: field} -> {:list_summary_by, field}
      %{delivery: field} -> {:list_summary_by, field}
      %{gestation_duration: field} -> {:list_summary_by, field}
      %{birth_location: field} -> {:list_summary_by, field}
      %{mother_age: field} -> {:list_summary_by, field}
      %{prenatal_consultation: field} -> {:list_summary_by, field}
      _filters -> {:list_total_by, nil}
    end
  end

  defp assign_to_socket(socket) do
    LiveView.assign(socket, :births_per_year_data, :emitted)
  end

  defp emit(data, socket) do
    LiveView.push_event(socket, "chart_data", build_js_data(data, socket.assigns))
  end

  defp build_js_data(births_per_year, assigns) do
    [from, to] =
      assigns
      |> Map.get(:filters, %{})
      |> Map.get(:year_period, [2000, 2019])

    data =
      from
      |> Range.new(to)
      |> Enum.to_list()
      |> Enum.zip(births_per_year)
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
      id: "births_per_year",
      data: %{
        type: "bar",
        data: %{
          labels: ["Nascidos vivos"],
          datasets: data
        },
        options: %{
          legend: false
        }
      }
    }
  end
end
