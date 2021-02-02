defmodule HealthBoardWeb.DashboardLive.ElementsData.Composite do
  @spec filter(map, atom, map, list(map)) :: map
  def filter(data, _field, _params, _filters) do
    data
  end

  @spec from(map, atom, map, list(map)) :: map
  def from(data, _field, _params, _filters) do
    data
  end
end
