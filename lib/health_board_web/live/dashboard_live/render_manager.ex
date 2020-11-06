defmodule HealthBoardWeb.DashboardLive.RenderManager do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2]
  alias Phoenix.LiveView
  alias HealthBoardWeb.DashboardLive.Renderings

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <div class="uk-section uk-section-xsmall">
      <%= Renderings.Header.render assigns %>
      <%= Renderings.Scalars.render assigns %>
      <%= Renderings.ChartsAndMaps.render assigns %>
    </div>
    <%= Renderings.JS.render assigns %>
    """
  end
end
