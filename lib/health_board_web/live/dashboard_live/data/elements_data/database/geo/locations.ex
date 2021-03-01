defmodule HealthBoardWeb.DashboardLive.ElementsData.Database.Geo.Locations do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.DashboardLive.ElementsData

  @spec list(map, atom, map, map, keyword) :: map
  def list(data, field, params, _filters, opts) do
    with {:ok, group} <- Map.fetch(params, "group"),
         {:ok, locations} <- list_locations(data, params, String.to_atom(group), opts) do
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

  defp list_locations(data, params, group, opts) do
    opts = Keyword.put(opts, :default, [])

    case Map.fetch(params, "related_location") do
      {:ok, related_location} ->
        case Map.fetch(data, String.to_atom(related_location)) do
          {:ok, location} -> {:ok, ElementsData.apply_and_cache(Locations, :related, [location, group], opts)}
          :error -> :error
        end

      :error ->
        {:ok, ElementsData.apply_and_cache(Locations, :list_by, [[group: group]], opts)}
    end
  end
end
