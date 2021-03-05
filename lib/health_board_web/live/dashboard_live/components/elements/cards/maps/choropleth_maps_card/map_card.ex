defmodule HealthBoardWeb.DashboardLive.Components.ChoroplethMapsCard.MapCard do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.BasicCard
  alias HealthBoardWeb.DashboardLive.Components.Card.Options
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons.{Eye, EyeOff}
  alias HealthBoardWeb.Helpers.Geo
  alias Phoenix.LiveView

  prop element, :map, required: true
  prop params, :map, required: true

  prop map_data, :map, required: true

  data timestamp, :integer, default: 0
  data show, :boolean, default: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <BasicCard name={{ @element.name }} show_footer={{ @element.show_options }} show_body={{ show?(@show, @timestamp, @map_data) }}>
      <div :show={{ show?(@show, @timestamp, @map_data) }} phx-hook="Map" id={{ @id }} class="h-96 max-h-screen"></div>

      <template slot="footer">
        <Options id={{ "options_#{@id}" }} element={{ maybe_put_ranges(@element, @map_data) }} params={{ @params }}>
          <button :on-click="toggle" title={{ if show?(@show, @timestamp, @map_data), do: "Ocultar mapa", else: "Visualizar mapa" }} class="hover:text-hb-ca dark:hover:text-hb-ca-dark focus:outline-none focus:text-hb-ca dark:focus:text-hb-ca-dark">
            <Eye :if={{ not show?(@show, @timestamp, @map_data) }} />
            <EyeOff :if={{ show?(@show, @timestamp, @map_data) }} />
          </button>
        </Options>
      </template>
    </BasicCard>
    """
  end

  @spec handle_event(String.t(), map, LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("toggle", _value, socket) do
    {:noreply, toggle(socket)}
  end

  defp toggle(%{assigns: %{map_data: %{timestamp: timestamp} = map_data, id: id, show: show?} = assigns} = socket) do
    if timestamp != assigns.timestamp do
      socket
      |> LiveView.push_event("map_data", prepare_map_data(map_data, id))
      |> LiveView.assign(timestamp: timestamp, show: true)
    else
      if not show? do
        socket
        |> LiveView.push_event("map_data", prepare_map_data(map_data, id))
        |> LiveView.assign(show: true)
      else
        LiveView.assign(socket, :show, false)
      end
    end
  end

  defp prepare_map_data(%{data: data, suffix: suffix}, id) do
    %{id: id, suffix: suffix, geojson: Geo.build_feature_collection(data)}
  end

  defp show?(true, timestamp, %{timestamp: timestamp}), do: true
  defp show?(_show?, _timestamp, _map_data), do: false

  defp maybe_put_ranges(element, %{ranges: ranges}), do: Map.put(element, :ranges, ranges)
  defp maybe_put_ranges(element, _map_data), do: element
end
