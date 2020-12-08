defmodule HealthBoardWeb.DashboardLive.CardData.DeathRateTable do
  alias HealthBoard.Contexts
  alias HealthBoardWeb.Helpers.Choropleth

  @spec fetch(map) :: map
  def fetch(map) do
    map
    |> Map.put(:view_data, fetch_table(map))
    |> put_in(
      [:filters, :morbidity_contexts],
      Enum.map(map.query_filters.morbidity_contexts, &Contexts.morbidity_name(&1))
    )
  end

  defp fetch_table(%{data: data} = map) do
    contexts = map.query_filters.morbidity_contexts

    %{
      locations: locations,
      locations_contexts_deaths: cases,
      locations_populations: populations
    } = data

    {headers, contexts} = fetch_headers(contexts)

    incidence_rates = fetch_incidence_rates(cases, populations)

    columns = Enum.map(contexts, &fetch_ranges(&1, incidence_rates))

    incidence_rates_per_location = Enum.group_by(incidence_rates, & &1.location_id)

    %{
      headers: headers,
      lines: Enum.map(locations, &fetch_line(&1, Map.get(incidence_rates_per_location, &1.id, []), columns))
    }
  end

  defp fetch_incidence_rates(year_cases, year_populations) do
    populations_per_location = Enum.group_by(year_populations, & &1.location_id)
    Enum.reduce(year_cases, [], &fetch_incidence_rate(&1, &2, populations_per_location))
  end

  defp fetch_incidence_rate(%{context: context, location_id: location_id, total: cases}, rates, populations) do
    [%{total: population}] = Map.get(populations, location_id, [%{total: 0}])

    if population > 0 and cases > 0 do
      [%{context: context, location_id: location_id, cases: cases, rate: cases * 100_000 / population}] ++ rates
    else
      rates
    end
  end

  defp fetch_ranges(context, incidence_rates) do
    ranges =
      incidence_rates
      |> Enum.filter(&(&1.context == context))
      |> Enum.map(& &1.rate)
      |> Choropleth.quartile()

    {context, ranges}
  end

  defp fetch_headers(contexts) do
    contexts
    |> Enum.map(fn context -> {Contexts.morbidity_name(context), context} end)
    |> Enum.sort(&(elem(&1, 0) <= elem(&2, 0)))
    |> Enum.unzip()
  end

  defp fetch_line(%{name: name}, incidence_rates, columns) do
    incidence_rates_per_context = Enum.group_by(incidence_rates, & &1.context)

    %{
      name: name,
      cells: Enum.map(columns, &fetch_cell(&1, incidence_rates_per_context))
    }
  end

  defp fetch_cell({context, ranges}, incidence_rates_per_context) do
    case Map.get(incidence_rates_per_context, context) do
      nil -> %{value: nil, group: 0, cases: 0}
      [%{cases: cases, rate: rate}] -> %{value: rate, cases: cases, group: Choropleth.group(ranges, rate)}
    end
  end
end
