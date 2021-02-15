defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Icons.Link do
  use Surface.Component
  alias Phoenix.LiveView

  prop svg_class, :css_class, default: "inline w-5 h-5"

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" class={{ @svg_class }}>
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />
    </svg>
    """
  end
end
