defmodule HealthBoardWeb.DashboardLive.Components.ChoroplethMapsCard.MapCard do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.BasicCard
  alias HealthBoardWeb.DashboardLive.Components.Card.Options
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Cooldown
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
        <Cooldown id={{ "cooldown_show_map_options_#{@id}" }} message="Aguarde a renderização deste mapa">
          <button :on-click="toggle" title={{ if show?(@show, @timestamp, @map_data), do: "Ocultar mapa", else: "Visualizar mapa" }} class="hover:text-hb-ca dark:hover:text-hb-ca-dark focus:outline-none focus:text-hb-ca dark:focus:text-hb-ca-dark">
            <Eye :if={{ not show?(@show, @timestamp, @map_data) }} />
            <EyeOff :if={{ show?(@show, @timestamp, @map_data) }} />
          </button>
        </Cooldown>
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
      maybe_show(socket, map_data, id, timestamp)
    else
      if not show? do
        maybe_show(socket, map_data, id)
      else
        LiveView.assign(socket, :show, false)
      end
    end
  end

  defp maybe_show(socket, %{data: data, suffix: suffix}, id, timestamp \\ nil) do
    case Geo.build_feature_collection(data) do
      {:ok, geojson_filename} ->
        Cooldown.trigger("cooldown_show_map_options_#{socket.assigns.id}")

        socket
        |> LiveView.push_event("map_data", %{id: id, suffix: suffix, geojson: geojson_filename})
        |> LiveView.assign(if is_nil(timestamp), do: [show: true], else: [timestamp: timestamp, show: true])

      :error ->
        socket
    end
  end

  defp show?(true, timestamp, %{timestamp: timestamp}), do: true
  defp show?(_show?, _timestamp, _map_data), do: false

  defp maybe_put_ranges(element, %{ranges: ranges}), do: Map.put(element, :ranges, ranges)
  defp maybe_put_ranges(element, _map_data), do: element
end
