defmodule HealthBoardWeb.DashboardLive.Components.IndeterminateLoading do
  use Surface.Component, slot: "body"

  alias Phoenix.LiveView

  @doc "Additional class"
  prop class, :string

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <svg class="hb-circular">
      <circle class="hb-path" cx="50" cy="50" r="20" fill="none" stroke-width="5" stroke-miterlimit="10"></circle>
    </svg>
    """
  end
end
