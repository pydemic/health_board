defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.DeathRate do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components
  alias HealthBoardWeb.Helpers.Humanize

  @spec choropleth_maps(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def choropleth_maps(_data, _params) do
    :ok
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
