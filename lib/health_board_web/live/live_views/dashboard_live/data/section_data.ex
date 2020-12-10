defmodule HealthBoardWeb.DashboardLive.SectionData do
  alias HealthBoardWeb.LiveComponents.DataSection

  @spec request_to_fetch(pid, map, map) :: :ok
  def request_to_fetch(pid, section, data) do
    send(pid, {:fetch_section, section, data})
    :ok
  end

  @spec fetch(pid, map, map) :: :ok
  def fetch(pid, %{id: id} = section, data) do
    sub_module =
      "#{id}"
      |> Recase.to_pascal()
      |> String.to_atom()

    result =
      __MODULE__
      |> Module.concat(sub_module)
      |> apply(:fetch, [pid, section, data])

    unless is_nil(result) do
      DataSection.fetch(id, result)
    end

    :ok
  end
end
