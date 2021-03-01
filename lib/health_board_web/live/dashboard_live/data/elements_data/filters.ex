defmodule HealthBoardWeb.DashboardLive.ElementsData.Filters do
  @spec get(map, atom, map, map, keyword) :: map
  def get(data, field, params, filters, _opts \\ []) do
    with %{"what" => what} <- params,
         {:ok, value} <- Map.fetch(filters, what) do
      Map.put(data, field, value)
    else
      _ -> data
    end
  end
end
