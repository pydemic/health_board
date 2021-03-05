defmodule HealthBoardWeb.DashboardLive.InfoManager do
  alias Phoenix.LiveView

  @spec handle(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def handle(socket, data) do
    case data do
      {:hook, event, payload} -> LiveView.push_event(socket, event, payload)
      _data -> socket
    end
  end
end
