defmodule HealthBoardWeb.DashboardLive.InfoManager do
  require Logger

  alias HealthBoardWeb.DashboardLive.EventData
  alias Phoenix.LiveView

  @spec handle_info(LiveView.Socket.t(), any()) :: LiveView.Socket.t()
  def handle_info(socket, {:exec_and_emit, function, data, event_context}) do
    {event_name, data} = EventData.build(function.(data), event_context)
    LiveView.push_event(socket, event_name, data)
  rescue
    error ->
      Logger.error(
        "Failed to execute function #{inspect(function)}.\n" <>
          Exception.message(error) <> "\n" <> Exception.format_stacktrace(__STACKTRACE__)
      )

      socket
  end

  def handle_info(socket, _data) do
    socket
  end
end
