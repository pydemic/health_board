defmodule HealthBoardWeb.DashboardLive do
  use Surface.LiveView
  alias HealthBoardWeb.DashboardLive.Components.{DynamicElement, Fragments.Otherwise, NoDashboard}
  alias Phoenix.LiveView

  prop dashboard, :map

  @impl LiveView
  @spec mount(map, map, LiveView.Socket.t()) :: {:ok, LiveView.Socket.t()}
  def mount(params, _session, socket), do: {:ok, __MODULE__.ParamsManager.mount(Surface.init(socket), params)}

  @impl LiveView
  @spec handle_params(map, String.t(), LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_params(params, _url, socket) do
    {:noreply,
     if socket.connected? do
       __MODULE__.ParamsManager.handle(socket, params)
     else
       socket
     end}
  end

  @impl LiveView
  @spec handle_event(String.t(), map, LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event(event, params, socket), do: {:noreply, __MODULE__.EventManager.handle(socket, event, params)}

  @impl LiveView
  @spec handle_info(any, LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_info(data, socket), do: {:noreply, __MODULE__.InfoManager.handle(socket, data)}

  @impl LiveView
  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Otherwise condition={{  Map.has_key?(assigns, :dashboard) }}>
      <DynamicElement element={{ @dashboard }} />
      <template slot="otherwise">
        <NoDashboard/>
      </template>
    </Otherwise>
    """
  end
end
