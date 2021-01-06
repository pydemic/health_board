defmodule HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard.{
    DailySummary,
    History,
    HospitalCapacity,
    PandemicSummary,
    Summary
  }

  alias Phoenix.LiveView

  prop dashboard, :map, required: true
  prop index, :integer, default: 0

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DailySummary show={{ @index == 0 }} group={{ Enum.at(@dashboard.groups, 0) }}/>
    <PandemicSummary show={{ @index == 1 }} group={{ Enum.at(@dashboard.groups, 1) }}/>
    <Summary show={{ @index == 2 }} group={{ Enum.at(@dashboard.groups, 2) }}/>
    <History show={{ @index == 3 }} group={{ Enum.at(@dashboard.groups, 3) }}/>
    <HospitalCapacity show={{ @index == 4 }} group={{ Enum.at(@dashboard.groups, 4) }}/>
    """
  end
end
