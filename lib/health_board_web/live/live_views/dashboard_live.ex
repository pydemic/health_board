defmodule HealthBoardWeb.DashboardLive do
  use Surface.LiveView

  alias HealthBoardWeb.DashboardLive.Fragments.{
    DemographicDashboard,
    NoDashboard
  }

  alias HealthBoardWeb.LiveComponents.Dashboard

  alias Phoenix.LiveView

  prop dashboard, :map
  prop filters, :map
  prop filters_options, :map
  prop data, :map

  @impl LiveView
  @spec mount(map, map, LiveView.Socket.t()) :: {:ok, LiveView.Socket.t()}
  def mount(params, _session, socket) do
    {:ok, __MODULE__.DataManager.initial_data(Surface.init(socket), params)}
  end

  @impl LiveView
  @spec handle_params(map, String.t(), LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_params(params, _url, socket) do
    if socket.connected? do
      {:noreply, __MODULE__.DataManager.update(socket, params)}
    else
      {:noreply, socket}
    end
  end

  @impl LiveView
  @spec handle_event(String.t(), map, LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event(event, params, socket) do
    {:noreply, __MODULE__.EventManager.handle_event(socket, params, event)}
  end

  @impl LiveView
  @spec handle_info(any(), LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_info(data, socket) do
    {:noreply, __MODULE__.InfoManager.handle_info(socket, data)}
  end

  @impl LiveView
  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    case assigns[:dashboard] do
      %{id: "demographic"} = dashboard ->
        ~H"""
        <Dashboard
          id={{ "demographic_dashboard" }}
          dashboard={{ dashboard }}
          filters={{ @filters }}
          filters_options={{ @filters_options }}
        >
          <DemographicDashboard dashboard={{ dashboard }} />
        </Dashboard>
        """

      _nil ->
        ~H"""
        <NoDashboard />
        """
    end
  end
end
