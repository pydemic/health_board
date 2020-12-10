defmodule HealthBoardWeb.DashboardLive.EventManager do
  alias HealthBoardWeb.DashboardLive.DataManager
  alias HealthBoardWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView

  @spec handle_event(LiveView.Socket.t(), map, String.t()) :: LiveView.Socket.t()
  def handle_event(socket, params, "apply_filter") do
    filters = merge_filters(socket, params)
    route = Routes.dashboard_path(socket, :index, filters)
    LiveView.push_patch(socket, to: route)
  end

  def handle_event(socket, params, "fetch_index") do
    filters = Map.merge(socket.assigns.filters, DataManager.parse_filters(params))
    route = Routes.dashboard_path(socket, :index, filters)
    LiveView.push_patch(socket, to: route)
  end

  def handle_event(socket, _params, _event) do
    socket
  end

  defp merge_filters(socket, %{"_target" => [target]} = params) do
    to_drop =
      case target do
        "state" -> [:health_region, :city]
        "health_region" -> [:city]
        _target -> []
      end

    Map.merge(
      Map.drop(socket.assigns.filters, to_drop),
      Map.drop(DataManager.parse_filters(params), to_drop)
    )
  end
end
