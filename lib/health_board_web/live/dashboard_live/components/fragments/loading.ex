defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Loading do
  use Surface.Component
  alias Phoenix.LiveView

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="inline-flex items-center px-4 py-2 text-hb-ba-dark dark:text-hb-ba-dark">
      <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-0" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75 text-hb-ba-dark dark:text-hb-ba-dark" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      Carregando
    </div>
    """
  end
end
