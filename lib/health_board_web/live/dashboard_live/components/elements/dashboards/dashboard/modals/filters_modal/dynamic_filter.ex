defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal.DynamicFilter do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal.Filters
  alias Phoenix.LiveView

  prop id, :string, required: true

  prop changes, :map, required: true
  prop filter, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    render_filter(assigns, assigns.filter.sid)
  end

  defp render_filter(assigns, "date") do
    ~H"""
    <div>
      <Filters.Date id={{ @id }} changes={{ @changes }} filter={{ @filter }} />
    </div>
    """
  end

  defp render_filter(assigns, "location") do
    ~H"""
    <div>
      <Filters.Location id={{ @id }} changes={{ @changes }} filter={{ @filter }} />
    </div>
    """
  end

  defp render_filter(assigns, _sid) do
    ~H"""
    <div></div>
    """
  end
end
