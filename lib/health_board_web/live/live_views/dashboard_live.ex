defmodule HealthBoardWeb.DashboardLive do
  use Surface.LiveView

  alias HealthBoard.Contexts.Info

  alias HealthBoardWeb.DashboardLive.Fragments.{
    AnalyticDashboard,
    DemographicDashboard,
    MorbidityDashboard,
    NoDashboard
  }

  alias Phoenix.LiveView

  @impl LiveView
  @spec mount(map(), map(), LiveView.Socket.t()) :: {:ok, LiveView.Socket.t()}
  def mount(params, _session, socket) do
    {:ok, __MODULE__.DataManager.initial_data(Surface.init(socket), params)}
  end

  @impl LiveView
  @spec handle_params(map(), String.t(), LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_params(params, _url, socket) do
    if socket.connected? do
      {:noreply, __MODULE__.DataManager.update(socket, params)}
    else
      {:noreply, socket}
    end
  end

  @impl LiveView
  @spec handle_event(String.t(), map(), LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
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
      %{id: "analytic"} = dashboard ->
        ~H"""
        <AnalyticDashboard dashboard={{ dashboard }}/>
        """

      %{id: "demographic"} = dashboard ->
        ~H"""
        <DemographicDashboard dashboard={{ dashboard }}/>
        """

      %{id: "morbidity"} = dashboard ->
        ~H"""
        <MorbidityDashboard dashboard={{ dashboard }}/>
        """

      _nil ->
        ~H"""
        <NoDashboard />
        """
    end
  end

  @spec request_dashboard_data(Info.Dashboard.t(), map) :: :ok
  def request_dashboard_data(dashboard, filters) do
    send(self(), {:fetch_dashboard_data, dashboard, filters})
  end
end
