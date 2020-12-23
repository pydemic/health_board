defmodule HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.{
    CoronavirusDailySummaryGroup,
    CoronavirusIncidenceGroup,
    CoronavirusDeathsGroup,
    CoronavirusHospitalizationsGroup
  }

  alias Phoenix.LiveView

  prop dashboard, :map, required: true
  prop index, :integer, default: 0

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <CoronavirusDailySummaryGroup show={{ @index == 0 }} group={{ Enum.at(@dashboard.groups, 0) }}/>
    <CoronavirusIncidenceGroup show={{ @index == 1 }} group={{ Enum.at(@dashboard.groups, 1) }}/>
    <CoronavirusDeathsGroup show={{ @index == 2 }} group={{ Enum.at(@dashboard.groups, 2) }}/>
    <CoronavirusHospitalizationsGroup show={{ @index == 3 }} group={{ Enum.at(@dashboard.groups, 3) }}/>
    """
  end
end
