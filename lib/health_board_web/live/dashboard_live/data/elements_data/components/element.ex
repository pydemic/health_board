defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.Element do
  @spec dashboard(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def dashboard(_data, _params) do
    :ok
  end

  @spec group(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def group(_data, _params) do
    :ok
  end

  @spec section(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def section(_data, _params) do
    :ok
  end
end
