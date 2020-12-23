defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.{
    FluSyndromeDailySummaryGroup,
    FluSyndromeIncidenceGroup
  }

  alias Phoenix.LiveView

  prop dashboard, :map, required: true
  prop index, :integer, default: 0

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <FluSyndromeDailySummaryGroup show={{ @index == 0 }} group={{ Enum.at(@dashboard.groups, 0) }}/>
    <FluSyndromeIncidenceGroup show={{ @index == 1 }} group={{ Enum.at(@dashboard.groups, 1) }}/>
    """
  end
end
