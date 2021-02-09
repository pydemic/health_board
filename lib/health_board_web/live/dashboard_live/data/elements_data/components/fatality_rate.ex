defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.FatalityRate do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components
  alias HealthBoardWeb.Helpers.Humanize

  @spec scalar(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def scalar(data, params) do
    {:ok, {:emit, %{value: do_scalar(data, params)}}}
  end

  defp do_scalar(data, params) do
    with {:ok, %{total: deaths}} <- Components.fetch_data(data, params, "deaths"),
         {:ok, %{total: cases}} <- Components.fetch_data(data, params, "incidence") do
      Humanize.number(fatality_rate(deaths, cases))
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
         {:ok, incidence_list} <- Components.fetch_data(data, params, "incidence_list") do
      %{lines: top_ten_table_lines(deaths_list, incidence_list)}
    else
      _ -> %{}
    end
  end

  defp top_ten_table_lines(deaths_list, incidence_list) do
    deaths_list
    |> Enum.map(&fatality_rate_from_incidence_list(&1, incidence_list))
    |> Enum.sort(&(&1.rate >= &2.rate))
    |> Enum.slice(0, 10)
    |> Enum.map(&top_ten_table_line/1)
  end

  defp fatality_rate_from_incidence_list(%{location_id: location_id, total: deaths} = death_map, incidence_list) do
    %{
      location: death_map.location,
      rate: fatality_rate(deaths, Enum.find_value(incidence_list, 0, &if(&1.location_id == location_id, do: &1.total)))
    }
  end

  defp top_ten_table_line(%{location: location, rate: rate}) do
    %{cells: [Humanize.location(location), Humanize.number(rate)]}
  end

  defp fatality_rate(_deaths, 0), do: 0
  defp fatality_rate(deaths, cases), do: 100 * deaths / cases
end
