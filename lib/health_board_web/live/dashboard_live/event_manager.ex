defmodule HealthBoardWeb.DashboardLive.EventManager do
  alias HealthBoardWeb.DashboardLive.DataManager
  alias HealthBoardWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView

  @spec handle_event(LiveView.Socket.t(), map, String.t()) :: LiveView.Socket.t()
  def handle_event(socket, params, "apply_filter") do
    filters =
      socket
      |> merge_filters(params)
      |> Enum.map(fn {k, v} -> {k, to_string(v)} end)

    route = Routes.dashboard_path(socket, :index, filters)
    LiveView.push_patch(socket, to: route)
  end

  def handle_event(socket, params, "fetch_index") do
    filters =
      socket.assigns.filters
      |> Map.merge(DataManager.parse_filters(params))
      |> Enum.map(fn {k, v} -> {k, to_string(v)} end)

    route = Routes.dashboard_path(socket, :index, filters)
    LiveView.push_patch(socket, to: route)
  end

  def handle_event(socket, _params, _event) do
    socket
  end

  defp merge_filters(socket, %{"_target" => target} = params) do
    to_drop =
      if Enum.any?(target) do
        [target | _target] = target

        case {target, params[target]} do
          {"state", "nil"} -> [:state, :health_region, :city]
          {"state", _state} -> [:health_region, :city]
          {"health_region", "nil"} -> [:health_region, :city]
          {"health_region", _health_region} -> [:city]
          {"city", "nil"} -> [:city]
          _target -> []
        end
      else
        []
      end

    socket.assigns.filters
    |> Map.drop(to_drop)
    |> Map.merge(Map.drop(DataManager.parse_filters(params), to_drop))
  end
end
