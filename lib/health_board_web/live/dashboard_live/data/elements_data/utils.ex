defmodule HealthBoardWeb.DashboardLive.ElementsData.Utils do
  @spec delete(map, atom, map, map, keyword) :: map
  def delete(data, _field, params, _filters, _opts \\ []) do
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
end
