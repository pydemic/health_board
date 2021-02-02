defmodule HealthBoardWeb.DashboardLive.InfoManager do
  alias Phoenix.LiveView

  @spec handle(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def handle(socket, _data) do
    socket
  end
end
