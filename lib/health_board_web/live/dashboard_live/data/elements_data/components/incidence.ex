defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.Incidence do
  @spec scalar(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def scalar(_data, _params) do
    {:ok, {:emit, %{value: "61.811"}}}
  end

  @spec top_ten_locations_table(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def top_ten_locations_table(_data, _params) do
    :ok
  end
end
