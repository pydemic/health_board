defmodule HealthBoardWeb.DashboardLive.GroupData do
  alias HealthBoardWeb.DashboardLive.Components.DataGroup

  @spec request_to_fetch(pid, map, map) :: :ok
  def request_to_fetch(pid, group, data) do
    send(pid, {:fetch_group, group, data})
    :ok
  end

  @spec fetch(pid, map, map) :: :ok
  def fetch(pid, %{id: id} = group, data) do
    sub_module =
      "#{id}"
      |> Recase.to_pascal()
      |> String.to_atom()

    result =
      __MODULE__
      |> Module.concat(sub_module)
      |> apply(:fetch, [pid, group, data])

    unless is_nil(result) do
      DataGroup.fetch(id, result)
    end

    :ok
  end
end
