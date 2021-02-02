defmodule HealthBoardWeb.DashboardLive.ParamsManager do
  alias HealthBoardWeb.DashboardLive.{DashboardsData, ElementsData}
  alias Phoenix.LiveView

  @spec mount(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def mount(socket, params) do
    if socket.changed[:dashboard] == true or not Map.has_key?(socket.assigns, :dashboard) do
      case DashboardsData.fetch(Map.get(params, "id", 1), params) do
        {:ok, dashboard} -> LiveView.assign(socket, dashboard: dashboard, page_title: dashboard.name)
        _not_found -> socket
      end
    else
      socket
    end
  end

  @spec handle(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def handle(socket, params) do
    with {:ok, dashboard} <- Map.fetch(socket.assigns, :dashboard) do
      group_index = String.to_integer(Map.get(params, "group_index", "0"))

      with %{child: group} <- Enum.at(dashboard.children, group_index) do
        ElementsData.request(socket, group)
      end
    end

    socket
  end
end
