defmodule HealthBoardWeb.DashboardLive.InfoManager do
  require Logger

  alias Phoenix.LiveView

  @spec handle_info(LiveView.Socket.t(), any()) :: LiveView.Socket.t()
  def handle_info(socket, _data) do
    socket
  end
end
