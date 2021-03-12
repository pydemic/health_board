defmodule HealthBoardWeb.DashboardLive.ElementsData.Utils do
  @spec delete(map, atom, map, map, keyword) :: map
  def delete(data, _field, params, _filters, _opts \\ []) do
    case Map.fetch(params, "what") do
      {:ok, what} -> Map.delete(data, String.to_atom(what))
      :error -> data
    end
  end

  @spec drop(map, atom, map, map, keyword) :: map
  def drop(data, _field, params, _filters, _opts \\ []) do
    case Map.fetch(params, "what") do
      {:ok, what} ->
        keys =
          what
          |> String.split(",")
          |> Enum.map(&String.to_atom/1)

        Map.drop(data, keys)

      :error ->
        data
    end
  end

  @spec take(map, atom, map, map, keyword) :: map
  def take(data, _field, params, _filters, _opts \\ []) do
    case Map.fetch(params, "what") do
      {:ok, what} ->
        keys =
          what
          |> String.split(",")
          |> Enum.map(&String.to_atom/1)

        Map.take(data, keys)

      :error ->
        data
    end
  end
end
