defmodule HealthBoardWeb.DashboardLive.DashboardData do
  alias HealthBoard.Contexts.Info
  alias HealthBoardWeb.DashboardLive.SectionData

  @spec assign(map) :: map
  def assign(%{dashboard: dashboard, data: data, filters: filters}) do
    fetch_sections_data(dashboard.sections, data, filters)
  end

  defp fetch_sections_data(dashboard_sections, data, filters) do
    for dashboard_section <- dashboard_sections, into: %{} do
      %{section: %{id: id, name: name, description: description} = section} = dashboard_section

      cards =
        section
        |> SectionData.new(data, filters)
        |> SectionData.fetch()
        |> SectionData.assign()

      {String.to_atom(id), %{name: name, description: description, cards: cards}}
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

  @spec new(Info.Dashboard.t(), map) :: map
  def new(dashboard, filters) do
    %{dashboard: dashboard, data: %{}, filters: filters}
  end
end
