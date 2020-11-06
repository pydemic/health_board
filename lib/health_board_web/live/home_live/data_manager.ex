defmodule HealthBoardWeb.HomeLive.DataManager do
  import Phoenix.LiveView, only: [assign: 3]
  alias HealthBoard.Contexts.Info
  alias Phoenix.LiveView

  @spec initial_data(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def initial_data(socket, _params) do
    assign(socket, :dashboards, Info.Dashboards.list())
  end

  @spec update(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def update(socket, _params) do
    socket
  end
end
