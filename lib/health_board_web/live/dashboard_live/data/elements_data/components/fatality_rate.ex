defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.FatalityRate do
  @spec scalar(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def scalar(_data, _params) do
    :ok
  end

  @spec top_ten_locations_table(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def top_ten_locations_table(_data, _params) do
    :ok
  end
end
