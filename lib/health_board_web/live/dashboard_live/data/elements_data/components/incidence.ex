defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.Incidence do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components
  alias HealthBoardWeb.Helpers.Humanize

  @spec scalar(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def scalar(data, params) do
    {:ok, {:emit, %{value: do_scalar(data, params)}}}
  end

  defp do_scalar(data, params) do
    case Components.fetch_data(data, params, "incidence") do
      {:ok, %{total: cases}} -> Humanize.number(cases)
      :error -> nil
    end
  end

  @spec top_ten_locations_table(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def top_ten_locations_table(data, params) do
    {:ok, {:emit, do_top_ten_locations_table(data, params)}}
  end

  defp do_top_ten_locations_table(data, params) do
    case Components.fetch_data(data, params, "incidence_list") do
      {:ok, incidence_list} -> %{lines: top_ten_table_lines(incidence_list)}
      :error -> %{}
    end
  end

  defp top_ten_table_lines(incidence_list) do
    incidence_list
    |> Enum.sort(&(&1.total >= &2.total))
    |> Enum.slice(0, 10)
    |> Enum.map(&top_ten_table_line/1)
  end

  defp top_ten_table_line(%{location: location, total: cases}) do
    %{cells: [Humanize.location(location), Humanize.number(cases)]}
  end
end
