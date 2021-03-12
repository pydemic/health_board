defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.DeathRate do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components

  @suffix "/ 100 mil habitantes"

  @deaths_scalar_param "deaths"
  @population_scalar_param "population"

  @deaths_per_location_param "#{@deaths_scalar_param}_per_location"
  @population_per_location_param "#{@population_scalar_param}_per_location"

  @spec scalar(map, map) :: {:ok, tuple} | :error
  def scalar(data, params) do
    with {:ok, %{total: t1}} <- Components.fetch_data(data, params, @deaths_scalar_param),
         {:ok, %{total: t2}} <- Components.fetch_data(data, params, @population_scalar_param) do
      Components.scalar(death_rate(t1, t2))
    else
      _result -> :error
    end
  end

  @spec top_ten_locations_table(map, map) :: {:ok, tuple} | :error
  def top_ten_locations_table(data, params) do
    with {:ok, [_ | _] = l1} <- Components.fetch_data(data, params, @deaths_per_location_param),
         {:ok, [_ | _] = l2} <- Components.fetch_data(data, params, @population_per_location_param) do
      l1
      |> Components.apply_in_total_per_location(l2, &death_rate/2)
      |> Components.top_ten_locations_table()
    else
      _result -> :error
    end
  end

  @spec choropleth_maps(map, map) :: {:ok, tuple} | :error
  def choropleth_maps(data, params) do
    Components.choropleth_maps(@suffix, fn prefix ->
      with {:ok, [_ | _] = l1} <- Components.fetch_data(data, params, "#{prefix}_#{@deaths_scalar_param}"),
           {:ok, [_ | _] = l2} <- Components.fetch_data(data, params, "#{prefix}_#{@population_scalar_param}"),
           {map_data, rates, _l2} <- Enum.reduce(l1, {[], [], l2}, &reduce_map_data/2),
           true <- Enum.any?(map_data) do
        {:ok, {map_data, rates}}
      else
        _result -> :error
      end
    end)
  end

  defp reduce_map_data(%{location_id: location_id} = s1, {map_data, rates, l2}) do
    with t1 when t1 > 0 <- s1.total,
         {s2, l2} <- Components.pop_with_location_id(l2, location_id),
         t2 when t2 > 0 <- s2.total do
      rate = death_rate(t1, t2)

      map_item = %{
        id: location_id,
        name: s1.location.name,
        value: rate
      }

      {[map_item | map_data], [rate | rates], l2}
    else
      _ -> {map_data, rates, l2}
    end
  end

  defp death_rate(deaths, population) do
    if is_number(deaths) and is_number(population) and population > 0 do
      100_000 * deaths / population
    else
      0.0
    end
  end
end
