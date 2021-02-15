defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.Options do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons
  alias Phoenix.LiveView

  prop element, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="px-6 py-2 flex justify-evenly content-center">
      <button :if={{ Enum.any?(@element.indicators) }} :on-click="show_indicators" class="focus:outline-none focus:border-indigo-700 focus:text-indigo-700">
        <Icons.Info />
      </button>

      <button :if={{ Enum.any?(@element.filters) }} :on-click="show_filters" class="focus:outline-none focus:border-indigo-700 focus:text-indigo-700">
        <Icons.Filter />
      </button>

      <button :if={{ Enum.any?(@element.sources) }} :on-click="show_sources" class="focus:outline-none focus:border-indigo-700 focus:text-indigo-700">
        <Icons.Source />
      </button>
    </div>
    """
  end

  @spec handle_event(String.t(), map, LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("show_filters", _value, %{assigns: %{element: element}} = socket) do
    Modals.show_filters(element.name, element.filters)

    {:noreply, socket}
  end

  def handle_event("show_indicators", _value, %{assigns: %{element: element}} = socket) do
    Modals.show_indicators(element.name, element.indicators)

    {:noreply, socket}
  end

  def handle_event("show_sources", _value, %{assigns: %{element: element}} = socket) do
    Modals.show_sources(element.name, element.sources)

    {:noreply, socket}
  end
end
