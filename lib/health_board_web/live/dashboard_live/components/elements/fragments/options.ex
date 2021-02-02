defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.Options do
  use Surface.Component
  alias Phoenix.LiveView

  prop element, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <a :if={{ Enum.any?(@element.indicators) }} href="/">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="inline w-5 h-5 text-gray-700">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    </a>

    <a :if={{ Enum.any?(@element.filters) }} href="/">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="inline w-5 h-5 text-gray-700">
        <path fill-rule="evenodd" d="M3 3a1 1 0 011-1h12a1 1 0 011 1v3a1 1 0 01-.293.707L12 11.414V15a1 1 0 01-.293.707l-2 2A1 1 0 018 17v-5.586L3.293 6.707A1 1 0 013 6V3z" clip-rule="evenodd"/>
      </svg>
    </a>

    <a :if={{ Enum.any?(@element.sources) }} href="/">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="inline w-5 h-5 text-gray-700">
        <path d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2h-1.528A6 6 0 004 9.528V4z"/>
        <path fill-rule="evenodd" d="M8 10a4 4 0 00-3.446 6.032l-1.261 1.26a1 1 0 101.414 1.415l1.261-1.261A4 4 0 108 10zm-2 4a2 2 0 114 0 2 2 0 01-4 0z" clip-rule="evenodd"/>
      </svg>
    </a>
    """
  end
end
