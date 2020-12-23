defmodule HealthBoardWeb.DashboardLive.DashboardData.Sars do
  alias Phoenix.LiveView

  @spec fetch(LiveView.Socket.t()) :: LiveView.Socket.t()
  def fetch(%{assigns: %{data: _data, filters: _filters, changed_filters: _changed_filters}} = socket) do
    socket
  end
end
