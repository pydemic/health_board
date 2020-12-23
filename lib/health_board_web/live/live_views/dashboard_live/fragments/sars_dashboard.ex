defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.{
    SarsDailySummaryGroup,
    SarsDeathsGroup,
    SarsHospitalizationsGroup,
    SarsIncidenceGroup
  }

  alias Phoenix.LiveView

  prop dashboard, :map, required: true
  prop index, :integer, default: 0

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <SarsDailySummaryGroup show={{ @index == 0 }} group={{ Enum.at(@dashboard.groups, 0) }}/>
    <SarsIncidenceGroup show={{ @index == 1 }} group={{ Enum.at(@dashboard.groups, 1) }}/>
    <SarsDeathsGroup show={{ @index == 2 }} group={{ Enum.at(@dashboard.groups, 2) }}/>
    <SarsHospitalizationsGroup show={{ @index == 3 }} group={{ Enum.at(@dashboard.groups, 3) }}/>
    """
  end
end
