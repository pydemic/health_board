defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.Samples do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components

  @label "Testes"

  @with_discarded_param "with_discarded"

  @scalar_param "samples"
  @positive_scalar_param "positive_#{@scalar_param}"
  @discarded_scalar_param "discarded_#{@scalar_param}"

  @daily_param "daily_#{@scalar_param}"
  @daily_positive_param "daily_#{@positive_scalar_param}"
  @daily_discarded_param "daily_#{@discarded_scalar_param}"

  @per_location_param "#{@scalar_param}_per_location"
  @per_location_positive_param "#{@positive_scalar_param}_per_location"
  @per_location_discarded_param "#{@discarded_scalar_param}_per_location"

  @spec daily_epicurve(map, map) :: {:ok, tuple} | :error
  def daily_epicurve(data, params) do
    with {:ok, list} <- fetch_daily_epicurve_list(data, params) do
      Components.daily_epicurve(list, @label)
    end
  end

  defp fetch_daily_epicurve_list(data, params) do
    if Map.has_key?(params, @with_discarded_param) do
      with {:ok, [_ | _] = l1} <- Components.fetch_data(data, params, @daily_positive_param),
           {:ok, [_ | _] = l2} <- Components.fetch_data(data, params, @daily_discarded_param) do
        {:ok, Components.sum_total_per_date(l1, l2)}
      else
        _result -> :error
      end
    else
      Components.fetch_data(data, params, @daily_param)
    end
  end

  @spec scalar(map, map) :: {:ok, tuple} | :error
  def scalar(data, params) do
    with {:ok, value} <- fetch_scalar_value(data, params) do
      Components.scalar(value)
    end
  end

  defp fetch_scalar_value(data, params) do
    if Map.has_key?(params, @with_discarded_param) do
      with {:ok, %{total: t1}} <- Components.fetch_data(data, params, @positive_scalar_param),
           {:ok, %{total: t2}} <- Components.fetch_data(data, params, @discarded_scalar_param) do
        {:ok, t1 + t2}
      else
        _result -> :error
      end
    else
      case Components.fetch_data(data, params, @scalar_param) do
        {:ok, %{total: total}} -> {:ok, total}
        _result -> :error
      end
    end
  end

  @spec top_ten_locations_table(map, map) :: {:ok, tuple} | :error
  def top_ten_locations_table(data, params) do
    with {:ok, list} <- fetch_top_ten_locations_list(data, params) do
      Components.top_ten_locations_table(list)
    end
  end

  defp fetch_top_ten_locations_list(data, params) do
    if Map.has_key?(params, @with_discarded_param) do
      with {:ok, [_ | _] = l1} <- Components.fetch_data(data, params, @per_location_positive_param),
           {:ok, [_ | _] = l2} <- Components.fetch_data(data, params, @per_location_discarded_param) do
        {:ok, Components.sum_total_per_location(l1, l2)}
      else
        _result -> :error
      end
    else
      Components.fetch_data(data, params, @per_location_param)
    end
  end
end
