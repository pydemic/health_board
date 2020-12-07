defmodule HealthBoardWeb.DashboardLive.DashboardData do
  require Logger

  alias HealthBoard.Contexts.Info
  alias HealthBoardWeb.DashboardLive.SectionData

  @spec assign(map) :: map
  def assign(%{dashboard: dashboard, data: data, filters: filters, root_pid: root_pid}) do
    dashboard.sections
    |> Task.async_stream(&fetch_section_data(&1, data, filters, root_pid), timeout: 10_000)
    |> Enum.reduce(%{}, fn {:ok, {k, v}}, map -> Map.put(map, k, v) end)
  end

  defp fetch_section_data(dashboard_section, data, filters, root_pid) do
    %{section: %{id: id, name: name, description: description} = section} = dashboard_section

    dashboard_section_id = String.to_atom(id)
    dashboard_section_data = %{name: name, description: description, cards: []}

    try do
      cards =
        section
        |> SectionData.new(data, filters, root_pid)
        |> SectionData.fetch()
        |> SectionData.assign()

      {dashboard_section_id, Map.put(dashboard_section_data, :cards, cards)}
    rescue
      error ->
        Logger.error(
          "Failed to build section #{id} data.\n" <>
            Exception.message(error) <> "\n" <> Exception.format_stacktrace(__STACKTRACE__)
        )

        {dashboard_section_id, dashboard_section_data}
    end
  end

  @spec fetch(map) :: map
  def fetch(%{dashboard: %{id: id}} = dashboard_data) do
    sub_module =
      "#{id}"
      |> Recase.to_pascal()
      |> String.to_atom()

    __MODULE__
    |> Module.concat(sub_module)
    |> apply(:fetch, [dashboard_data])
  end

  @spec new(Info.Dashboard.t(), map, pid) :: map
  def new(dashboard, filters, root_pid) do
    %{dashboard: dashboard, data: %{}, filters: filters, root_pid: root_pid}
  end
end
