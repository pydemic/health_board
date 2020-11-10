defmodule HealthBoardWeb.DashboardLive.GridComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <div
      class="uk-grid uk-flex-center uk-grid-small uk-grid-match uk-text-center uk-margin-left uk-margin-right uk-animation-fade"
      uk-grid
    >
      <%= @inner_content.(assigns) %>
    </div>
    """
  end
end
