defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Icons.Moon do
  use Surface.Component
  alias Phoenix.LiveView

  prop svg_class, :css_class, default: "inline w-5 h-5"

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" class={{ @svg_class }}>
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
    </svg>
    """
  end
end
