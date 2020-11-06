defmodule HealthBoardWeb.DashboardLive.EventManager do
  alias Phoenix.LiveView

  @spec handle_event(LiveView.Socket.t(), map(), String.t()) :: LiveView.Socket.t()
  def handle_event(socket, _params, _filter) do
    socket
  end
end
