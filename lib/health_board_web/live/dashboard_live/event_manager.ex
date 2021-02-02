defmodule HealthBoardWeb.DashboardLive.EventManager do
  alias Phoenix.LiveView

  @spec handle(LiveView.Socket.t(), String.t(), map) :: LiveView.Socket.t()
  def handle(socket, _event, _params) do
    socket
  end
end
