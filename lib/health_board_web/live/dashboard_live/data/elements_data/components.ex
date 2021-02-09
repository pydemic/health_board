defmodule HealthBoardWeb.DashboardLive.ElementsData.Components do
  @spec fetch_data(map, map, String.t()) :: {:ok, any} | :error
  def fetch_data(data, params, key), do: Map.fetch(data, String.to_atom(params[key] || key))
end
