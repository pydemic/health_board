defmodule HealthBoardWeb.DashboardLive.CardData.DeathRateTable do
  alias HealthBoard.Contexts
  alias HealthBoardWeb.Helpers.Choropleth

  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = card_data) do
    case fetch_morbidity_contexts(filters) do
      {:ok, morbidity_contexts} -> Map.put(card_data, :view_data, fetch_table(data, morbidity_contexts))
      _error -> card_data
    end
  end

  defp fetch_morbidity_contexts(filters) do
    case Map.get(filters, "morbidity_contexts") do
      nil -> {:error, :morbidity_contexts_missing}
      morbidity_contexts -> {:ok, morbidity_contexts}
    end
  end

  defp fetch_table(data, morbidity_contexts) do
    %{
      locations: locations,
      locations_year_deaths: year_deaths,
      locations_year_populations: year_populations
    } = data

    {headers, morbidity_contexts} = fetch_headers(morbidity_contexts)

    death_rates = fetch_death_rates(year_deaths, year_populations)

    columns = Enum.map(morbidity_contexts, &fetch_ranges(&1, death_rates))

    death_rates_per_location = Enum.group_by(death_rates, & &1.location_id)

    lines = Enum.map(locations, &fetch_line(&1, Map.get(death_rates_per_location, &1.id, []), columns))

    %{
      headers: headers,
      lines: lines
    }
  end

  defp fetch_death_rates(year_deaths, year_populations) do
    populations_per_location = Enum.group_by(year_populations, & &1.location_id)
    {rates, _populations} = Enum.reduce(year_deaths, {[], populations_per_location}, &fetch_death_rate/2)
    rates
  end

  defp fetch_death_rate(%{context: context, location_id: location_id, total: cases}, {rates, populations}) do
    {[%{total: population}], populations} = Map.pop(populations, location_id, [%{total: 0}])

    if population > 0 and cases > 0 do
      {[%{context: context, location_id: location_id, cases: cases, rate: cases * 100 / population}] ++ rates,
       populations}
    else
      {rates, populations}
    end
  end

  defp fetch_ranges(morbidity_context, death_rates) do
    ranges =
      death_rates
      |> Enum.filter(&(&1.context == morbidity_context))
      |> Enum.map(& &1.rate)
      |> Choropleth.quartile()

    {morbidity_context, ranges}
  end

  defp fetch_headers(morbidity_contexts) do
    morbidity_contexts
    |> Enum.map(fn context -> {Contexts.morbidity_name(context), context} end)
    |> Enum.sort(&(elem(&1, 0) <= elem(&2, 0)))
    |> Enum.unzip()
  end

  defp fetch_line(%{name: name}, death_rates, columns) do
    death_rates_per_context = Enum.group_by(death_rates, & &1.context)

    %{
      name: name,
      cells: Enum.map(columns, &fetch_cell(&1, death_rates_per_context))
    }
  end

  defp fetch_cell({morbidity_context, ranges}, death_rates_per_context) do
    case Map.get(death_rates_per_context, morbidity_context) do
      nil -> %{value: nil, color: "0", cases: 0}
      [%{cases: cases, rate: rate}] -> %{value: rate, cases: cases, color: Choropleth.color(ranges, rate)}
    end
  end
end
