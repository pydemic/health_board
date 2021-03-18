defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.HospitalizationFatalityRate do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components

  @deaths_scalar_param "deaths"
  @hospitalizations_scalar_param "hospitalizations"

  @deaths_per_location_param "#{@deaths_scalar_param}_per_location"
  @hospitalizations_per_location_param "#{@hospitalizations_scalar_param}_per_location"

  @spec scalar(map, map) :: {:ok, tuple} | :error
  def scalar(data, params) do
    with {:ok, %{total: t1}} <- Components.fetch_data(data, params, @deaths_scalar_param),
         {:ok, %{total: t2}} <- Components.fetch_data(data, params, @hospitalizations_scalar_param) do
      Components.scalar(hospitalization_fatality_rate(t1, t2))
    else
      _result -> :error
    end
  end

  @spec top_ten_locations_table(map, map) :: {:ok, tuple} | :error
  def top_ten_locations_table(data, params) do
    with {:ok, [_ | _] = l1} <- Components.fetch_data(data, params, @deaths_per_location_param),
         {:ok, [_ | _] = l2} <- Components.fetch_data(data, params, @hospitalizations_per_location_param) do
      l1
      |> Components.apply_in_total_per_location(l2, &hospitalization_fatality_rate/2)
      |> Components.top_ten_locations_table()
    else
      _result -> :error
    end
  end

  defp hospitalization_fatality_rate(deaths, hospitalizations) do
    if is_number(deaths) and is_number(hospitalizations) and hospitalizations > 0 do
      min(100 * deaths / hospitalizations, 100.0)
    else
      0.0
    end
  end
end
