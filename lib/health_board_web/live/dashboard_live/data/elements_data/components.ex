defmodule HealthBoardWeb.DashboardLive.ElementsData.Components do
  @spec fetch_data(map, map, String.t(), keyword) :: {:ok, any} | :error
  def fetch_data(data, params, key, _opts \\ []), do: Map.fetch(data, String.to_atom(params[key] || key))
end
