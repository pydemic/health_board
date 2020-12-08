defmodule HealthBoardWeb.DashboardLive.CardData do
  @spec fetch(atom, map) :: map
  def fetch(id, payload) do
    sub_module =
      "#{id}"
      |> Recase.to_pascal()
      |> String.to_atom()

    __MODULE__
    |> Module.concat(sub_module)
    |> apply(:fetch, [payload])
  end
end
