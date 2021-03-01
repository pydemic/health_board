defmodule HealthBoardWeb.DashboardLive.ParamsManager do
  alias HealthBoardWeb.DashboardLive.{DashboardsData, ElementsData}
  alias Phoenix.LiveView

  @spec fetch_dashboard(LiveView.Socket.t(), map, keyword) :: LiveView.Socket.t()
  def fetch_dashboard(socket, params, opts \\ []) do
    case DashboardsData.fetch(params["id"], params, opts) do
      {:ok, dashboard} -> LiveView.assign(socket, dashboard: dashboard, page_title: dashboard.name)
      _not_found -> socket
    end
  end

  @spec emit_group_data(LiveView.Socket.t(), map, keyword) :: :ok
  def emit_group_data(socket, params, opts \\ []) do
    with {:ok, dashboard} <- Map.fetch(socket.assigns, :dashboard) do
      group_index = String.to_integer(Map.get(params, "group_index", "0"))

      with %{child: group} <- Enum.at(dashboard.children, group_index) do
        ElementsData.emit(socket, group, opts)
      end
    end

    :ok
  end

  @spec mount(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def mount(socket, params) do
    socket = LiveView.assign(socket, dark_mode: params["dark_mode"] == "true")

    if socket.changed[:dashboard] == true or not Map.has_key?(socket.assigns, :dashboard) do
      fetch_dashboard(socket, params)
    else
      socket
    end
  end

  @spec handle(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def handle(socket, params) do
    socket =
      if socket.changed[:dashboard] != true do
        fetch_dashboard(socket, params)
      else
        socket
      end

    emit_group_data(socket, params)

    LiveView.assign(socket, :dark_mode, params["dark_mode"] == "true")
  end
end
