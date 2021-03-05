defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.DeathRate do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components
  alias HealthBoardWeb.Helpers.{Choropleth, Humanize}

  @spec choropleth_maps(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def choropleth_maps(data, params) do
    {:ok, {:emit, do_choropleth_maps(data, params)}}
  end

  defp do_choropleth_maps(data, params) do
    %{}
    |> maybe_put_map_data(:regions_data, death_rates_from_location_groups(data, params, :regions))
    |> maybe_put_map_data(:states_data, death_rates_from_location_groups(data, params, :states))
    |> maybe_put_map_data(:health_regions_data, death_rates_from_location_groups(data, params, :health_regions))
    |> maybe_put_map_data(:cities_data, death_rates_from_location_groups(data, params, :cities))
    |> validate_map_data()
  end

  defp death_rates_from_location_groups(data, params, prefix) do
    with {:ok, deaths_list} when is_list(deaths_list) <- Components.fetch_data(data, params, "#{prefix}_deaths"),
         {:ok, pop_list} when is_list(pop_list) <- Components.fetch_data(data, params, "#{prefix}_population"),
         {map_data, rates, locations_ids, _} <- Enum.reduce(deaths_list, {[], [], [], pop_list}, &reduce_map_data/2),
         true <- Enum.any?(locations_ids) do
      ranges = Choropleth.weighted_distribution(rates)

      {:ok,
       %{
         ranges: ranges,
         data: Enum.map(map_data, &wrap_map_item(&1, ranges)),
         suffix: "/ 100 mil habitantes",
         timestamp: :os.system_time()
       }}
    else
      _result -> :error
    end
  end

  defp reduce_map_data(%{location_id: location_id} = deaths_map, {map_data, rates, locations_ids, population_list}) do
    with deaths when deaths > 0 <- deaths_map.total,
         {population_map, population_list} <- pop_population_with_location_id(population_list, location_id),
         population when population > 0 <- population_map.total do
      rate = death_rate(deaths, population)

      map_item = %{
        id: location_id,
        name: deaths_map.location.name,
        value: rate
      }

      {[map_item | map_data], [rate | rates], [location_id | locations_ids], population_list}
    else
      _ -> {map_data, rates, locations_ids, population_list}
    end
  end

  defp pop_population_with_location_id(population_list, location_id) do
    Enum.reduce(population_list, {nil, []}, fn
      %{location_id: ^location_id} = population, {nil, population_list} -> {population, population_list}
      population, {result, population_list} -> {result, [population | population_list]}
    end)
  end

  defp wrap_map_item(%{value: value} = item, ranges) do
    Map.merge(item, %{value: Humanize.number(value), group: Choropleth.group(ranges, value)})
  end

  defp maybe_put_map_data(map, key, {:ok, map_data}), do: Map.put(map, key, map_data)
  defp maybe_put_map_data(map, _key, _result), do: map

  defp validate_map_data(map_data) do
    if Enum.any?(map_data) do
      Map.put(map_data, :length, length(Map.keys(map_data)))
    else
      Map.put(map_data, :error?, true)
    end
  end

  @spec scalar(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def scalar(data, params) do
    {:ok, {:emit, %{value: do_scalar(data, params)}}}
  end

  defp do_scalar(data, params) do
    with {:ok, %{total: deaths}} <- Components.fetch_data(data, params, "deaths"),
         {:ok, %{total: population}} <- Components.fetch_data(data, params, "population") do
      Humanize.number(death_rate(deaths, population))
    else
      _ -> nil
    end
  end

  @spec top_ten_locations_table(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def top_ten_locations_table(data, params) do
    {:ok, {:emit, do_top_ten_locations_table(data, params)}}
  end

  defp do_top_ten_locations_table(data, params) do
    with {:ok, deaths_list} <- Components.fetch_data(data, params, "deaths_list"),
         {:ok, population_list} <- Components.fetch_data(data, params, "population_list") do
      %{lines: top_ten_table_lines(deaths_list, population_list)}
    else
      _ -> %{}
    end
  end

  defp top_ten_table_lines(deaths_list, population_list) do
    deaths_list
    |> Enum.map(&death_rate_from_population_list(&1, population_list))
    |> Enum.sort(&(&1.rate >= &2.rate))
    |> Enum.slice(0, 10)
    |> Enum.map(&top_ten_table_line/1)
  end

  defp death_rate_from_population_list(%{location_id: location_id, total: deaths} = death_map, population_list) do
    %{
      location: death_map.location,
      rate: death_rate(deaths, Enum.find_value(population_list, 0, &if(&1.location_id == location_id, do: &1.total)))
    }
  end

  defp top_ten_table_line(%{location: location, rate: rate}) do
    %{cells: [{Humanize.location(location), %{location: location.id}}, Humanize.number(rate)]}
  end

  defp death_rate(_deaths, 0), do: 0
  defp death_rate(deaths, population), do: 100_000 * deaths / population
end
