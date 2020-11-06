defmodule HealthBoardWeb.HomeLive.EventManager do
  import Phoenix.LiveView, only: [assign: 3]
  alias Phoenix.LiveView

  @spec handle_event(LiveView.Socket.t(), map(), String.t()) :: LiveView.Socket.t()
  def handle_event(socket, _params, "toggle_dashboards") do
    show_dashboards? = Map.get(socket.assigns, :show_dashboards, true)
    assign(socket, :show_dashboards, not show_dashboards?)
  end

  def handle_event(socket, _params, "toggle_new_dashboard") do
    show_new_dashboard? = Map.get(socket.assigns, :show_new_dashboard, true)
    assign(socket, :show_new_dashboard, not show_new_dashboard?)
  end

  def handle_event(socket, _params, _filter) do
    socket
  end
end
