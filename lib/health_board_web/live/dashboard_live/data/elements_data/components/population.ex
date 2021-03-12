defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.Population do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components

  @scalar_param "population"

  @spec scalar(map, map) :: {:ok, tuple} | :error
  def scalar(data, params) do
    case Components.fetch_data(data, params, @scalar_param) do
      {:ok, %{total: total}} -> Components.scalar(total)
      _result -> :error
    end
  end
end
