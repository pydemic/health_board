defmodule HealthBoardWeb.DashboardLive.Components.Card.Options do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons.{Filter, Info, Source, Tag}
  alias Phoenix.LiveView

  prop element, :map, required: true
  prop params, :map, default: %{}

  slot default

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="px-5 py-2 flex justify-evenly content-center">
      <button :if={{ Enum.any?(@element.indicators) }} :on-click="show_indicators" title={{ "Indicadores" }} class="hover:text-hb-ca dark:hover:text-hb-ca-dark focus:outline-none focus:text-hb-ca dark:focus:text-hb-ca-dark">
        <Info />
      </button>

      <button :if={{ Enum.any?(@element.filters) }} :on-click="show_filters" title={{ "Filtros" }} class="hover:text-hb-ca dark:hover:text-hb-ca-dark focus:outline-none focus:text-hb-ca dark:focus:text-hb-ca-dark">
        <Filter />
      </button>

      <button :if={{ Enum.any?(@element.sources) }} :on-click="show_sources" title={{ "Fontes" }} class="hover:text-hb-ca dark:hover:text-hb-ca-dark focus:outline-none focus:text-hb-ca dark:focus:text-hb-ca-dark">
        <Source />
      </button>

      <button :if={{ Enum.any?(@element.ranges) }} :on-click="show_ranges" title={{ "Legenda" }} class="hover:text-hb-ca dark:hover:text-hb-ca-dark focus:outline-none focus:text-hb-ca dark:focus:text-hb-ca-dark">
        <Tag />
      </button>

      <slot name="default" />
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

  def handle_event("show_ranges", _value, %{assigns: %{element: element}} = socket) do
    Modals.show_ranges(element.name, element.ranges)

    {:noreply, socket}
  end

  def handle_event("show_sources", _value, %{assigns: %{element: element}} = socket) do
    Modals.show_sources(element.name, element.sources)

    {:noreply, socket}
  end
end
