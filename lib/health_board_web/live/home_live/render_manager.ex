defmodule HealthBoardWeb.HomeLive.RenderManager do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2]
  alias Phoenix.LiveView
  alias HealthBoardWeb.HomeLive.Renderings

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <%= Renderings.Dashboards.render assigns %>
    """
  end
end
