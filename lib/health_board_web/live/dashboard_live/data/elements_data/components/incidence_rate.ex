defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.IncidenceRate do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components
  alias HealthBoardWeb.Helpers.Humanize

  @spec scalar(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def scalar(data, params) do
    {:ok, {:emit, %{value: do_scalar(data, params)}}}
  end

  defp do_scalar(data, params) do
    with {:ok, %{total: cases}} <- Components.fetch_data(data, params, "incidence"),
         {:ok, %{total: population}} <- Components.fetch_data(data, params, "population") do
      Humanize.number(incidence_rate(cases, population))
    else
      _ -> nil
    end
  end

  @spec top_ten_locations_table(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def top_ten_locations_table(data, params) do
    {:ok, {:emit, do_top_ten_locations_table(data, params)}}
  end

  defp do_top_ten_locations_table(data, params) do
    with {:ok, incidence_list} <- Components.fetch_data(data, params, "incidence_list"),
         {:ok, population_list} <- Components.fetch_data(data, params, "population_list") do
      %{lines: top_ten_table_lines(incidence_list, population_list)}
    else
      _ -> %{}
    end
  end

  defp top_ten_table_lines(incidence_list, population_list) do
    incidence_list
    |> Enum.map(&incidence_rate_from_population_list(&1, population_list))
    |> Enum.sort(&(&1.rate >= &2.rate))
    |> Enum.slice(0, 10)
    |> Enum.map(&top_ten_table_line/1)
  end

  defp incidence_rate_from_population_list(%{location_id: location_id, total: cases} = incidence, population_list) do
    %{
      location: incidence.location,
      rate: incidence_rate(cases, Enum.find_value(population_list, 0, &if(&1.location_id == location_id, do: &1.total)))
    }
  end

  defp top_ten_table_line(%{location: location, rate: rate}) do
    %{cells: [Humanize.location(location), Humanize.number(rate)]}
  end

  defp incidence_rate(_cases, 0), do: 0
  defp incidence_rate(cases, population), do: 100_000 * cases / population
end
