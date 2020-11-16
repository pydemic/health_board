defmodule HealthBoardWeb.DashboardLive.Renderings.Header do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2]
  alias HealthBoardWeb.DashboardLive.Renderings
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    Renderings.maybe_render(assigns, :dashboard, &title/1)
  end

  defp title(assigns) do
    ~L"""
    <nav class="uk-navbar-container uk-navbar-transparent uk-light hb-page-navbar" uk-navbar>
      <a class="uk-navbar-item uk-logo" href=""><%= @dashboard.name %></a>
    </nav>
    """
  end
end
