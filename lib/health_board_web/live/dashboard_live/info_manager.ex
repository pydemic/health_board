defmodule HealthBoardWeb.DashboardLive.InfoManager do
  require Logger

  alias HealthBoardWeb.DashboardLive.IndicatorsData
  alias Phoenix.LiveView

  @spec handle_info(LiveView.Socket.t(), any()) :: LiveView.Socket.t()
  def handle_info(socket, {:fetch_card_data, dashboard_card, params}) do
    %{card: %{id: id} = card} = dashboard_card

    socket
    |> IndicatorsData.new(String.to_atom(id), card, params)
    |> IndicatorsData.fetch()
    |> IndicatorsData.assign()
  rescue
    error ->
      Logger.error(Exception.message(error))
      Logger.error(Exception.format_stacktrace(__STACKTRACE__))
      socket
  end

  def handle_info(socket, _data) do
    socket
  end
end
