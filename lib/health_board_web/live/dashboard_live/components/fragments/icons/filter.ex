defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Icons.Filter do
  use Surface.Component
  alias Phoenix.LiveView

  prop svg_class, :css_class, default: "inline w-5 h-5"

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <svg fill="currentColor" viewBox="0 0 20 20" class={{ @svg_class }}>
      <path fill-rule="evenodd" d="M3 3a1 1 0 011-1h12a1 1 0 011 1v3a1 1 0 01-.293.707L12 11.414V15a1 1 0 01-.293.707l-2 2A1 1 0 018 17v-5.586L3.293 6.707A1 1 0 013 6V3z" clip-rule="evenodd"/>
    </svg>
    """
  end
end
