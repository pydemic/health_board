defmodule HealthBoardWeb.DashboardLive.RenderManager do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2]

  alias HealthBoardWeb.DashboardLive.Renderings
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <%= Renderings.Header.render assigns %>
    <%= Renderings.maybe_render assigns, :analytic, &Renderings.Analytic.render/1 %>
    <%= Renderings.maybe_render assigns, :demographic, &Renderings.Demographic.render/1 %>
    <%= Renderings.maybe_render assigns, :dengue, &Renderings.Dengue.render/1 %>
    <%= Renderings.maybe_render assigns, :violence, &Renderings.Violence.render/1 %>
    """
  end
end
