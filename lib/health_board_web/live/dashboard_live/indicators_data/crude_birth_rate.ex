defmodule HealthBoardWeb.DashboardLive.IndicatorsData.CrudeBirthRate do
  alias Phoenix.LiveView
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @spec fetch(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def fetch(socket, filters) do
    socket
    |> maybe_fetch_population_data(filters)
    |> maybe_fetch_births_data(filters)
    |> calculate()
    |> assign_to_socket(socket)
  end

  defp maybe_fetch_population_data(socket, filters) do
    case socket.assigns do
      %{population_data: _} -> socket
      _assigns -> IndicatorsData.Population.fetch(socket, filters)
    end
  end

  defp maybe_fetch_births_data(socket, filters) do
    case socket.assigns do
      %{births_data: _} -> socket
      _assigns -> IndicatorsData.Births.fetch(socket, filters)
    end
  end

  defp calculate(%{assigns: %{population_data: population, births_data: births}}) do
    div(births * 1_000, population)
  end

  defp assign_to_socket(data, socket) do
    LiveView.assign(socket, :crude_birth_rate_data, data)
  end
end
