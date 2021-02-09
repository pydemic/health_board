defmodule HealthBoardWeb.DashboardLive.ElementsData.Database.Geo.Locations do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.DashboardLive.ElementsData

  @spec list(map, atom, map, map) :: map
  def list(data, field, params, _filters) do
    with {:ok, group} <- Map.fetch(params, "group"),
         {:ok, locations} <- list_locations(data, params, String.to_atom(group)) do
      locations =
        case Map.fetch(params, "get") do
          {:ok, get} ->
            get = String.to_atom(get)
            Enum.map(locations, &Map.get(&1, get))

          :error ->
            locations
        end

      Map.put(data, field, locations)
    else
      _ -> data
    end
  end

  defp list_locations(data, params, group) do
    case Map.fetch(params, "related_location") do
      {:ok, related_location} ->
        case Map.fetch(data, String.to_atom(related_location)) do
          {:ok, location} -> {:ok, ElementsData.database_data(Locations, :related, [location, group])}
          :error -> :error
        end

      :error ->
        {:ok, ElementsData.database_data(Locations, :list_by, [[group: group]])}
    end
  end
end
