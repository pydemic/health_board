defmodule HealthBoardWeb.DashboardLive.Components.Fragments.NA do
  use Surface.Component
  alias Phoenix.LiveView

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <p class="text-2xl font-bold text-hb-ba-dark dark:text-hb-ba-dark">
      N/A
    </p>
    """
  end
end
