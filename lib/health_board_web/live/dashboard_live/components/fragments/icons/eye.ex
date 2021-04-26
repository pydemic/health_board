defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Icons.Eye do
  use Surface.Component
  alias Phoenix.LiveView

  prop svg_class, :css_class, default: "inline w-5 h-5"
  prop stroke_width, :string, default: "2"

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" class={{ @svg_class }}>
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width={{ @stroke_width }} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width={{ @stroke_width }} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
    </svg>
    """
  end
end
