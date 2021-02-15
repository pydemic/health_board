defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Icons.ChevronDown do
  use Surface.Component
  alias Phoenix.LiveView

  prop svg_class, :css_class, default: "inline w-2 h-2"

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" class={{ @svg_class }}>
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
    </svg>
    """
  end
end
