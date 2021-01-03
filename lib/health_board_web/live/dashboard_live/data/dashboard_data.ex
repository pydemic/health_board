defmodule HealthBoardWeb.DashboardLive.DashboardData do
  alias Phoenix.LiveView

  @spec fetch(LiveView.Socket.t()) :: LiveView.Socket.t()
  def fetch(socket) do
    sub_module =
      "#{socket.assigns.dashboard.id}"
      |> Recase.to_pascal()
      |> String.to_atom()

    __MODULE__
    |> Module.concat(sub_module)
    |> apply(:fetch, [socket])
  end
end
