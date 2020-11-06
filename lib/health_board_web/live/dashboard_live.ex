defmodule HealthBoardWeb.DashboardLive do
  use Phoenix.LiveView, layout: {HealthBoardWeb.LayoutView, "live.html"}
  alias HealthBoardWeb.DashboardLive
  alias Phoenix.LiveView

  @impl Phoenix.LiveView
  @spec mount(map(), map(), LiveView.Socket.t()) :: {:ok, LiveView.Socket.t()}
  def mount(params, _session, socket) do
    {:ok, DashboardLive.DataManager.initial_data(socket, params)}
  end

  @impl Phoenix.LiveView
  @spec handle_params(map(), String.t(), LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_params(params, _url, socket) do
    {:noreply, DashboardLive.DataManager.update(socket, params)}
  end

  @impl Phoenix.LiveView
  @spec handle_event(String.t(), map(), LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event(event, params, socket) do
    {:noreply, DashboardLive.EventManager.handle_event(socket, params, event)}
  end

  @impl Phoenix.LiveView
  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    DashboardLive.RenderManager.render(assigns)
  end
end
