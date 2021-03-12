defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.FatalityRate do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components

  @deaths_scalar_param "deaths"
  @incidence_scalar_param "incidence"

  @deaths_per_location_param "#{@deaths_scalar_param}_per_location"
  @incidence_per_location_param "#{@incidence_scalar_param}_per_location"

  @spec scalar(map, map) :: {:ok, tuple} | :error
  def scalar(data, params) do
    with {:ok, %{total: t1}} <- Components.fetch_data(data, params, @deaths_scalar_param),
         {:ok, %{total: t2}} <- Components.fetch_data(data, params, @incidence_scalar_param) do
      Components.scalar(fatality_rate(t1, t2))
    else
      _result -> :error
    end
  end

  @spec top_ten_locations_table(map, map) :: {:ok, tuple} | :error
  def top_ten_locations_table(data, params) do
    with {:ok, [_ | _] = l1} <- Components.fetch_data(data, params, @deaths_per_location_param),
         {:ok, [_ | _] = l2} <- Components.fetch_data(data, params, @incidence_per_location_param) do
      l1
      |> Components.apply_in_total_per_location(l2, &fatality_rate/2)
      |> Components.top_ten_locations_table()
    else
      _result -> :error
    end
  end

  defp fatality_rate(deaths, incidence) do
    if is_number(deaths) and is_number(incidence) and incidence > 0 do
      100 * deaths / incidence
    else
      0.0
    end
  end
end
