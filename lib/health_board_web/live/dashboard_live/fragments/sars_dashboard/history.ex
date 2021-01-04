defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.History do
  use Surface.Component

  alias __MODULE__.{
    HistoryDeaths,
    HistoryHospitalizations,
    HistoryIncidence,
    HistoryTests
  }

  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <HistoryIncidence section={{ Enum.at(@group.sections, 0) }} />
      <HistoryDeaths section={{ Enum.at(@group.sections, 1) }} />
      <HistoryHospitalizations section={{ Enum.at(@group.sections, 2) }} />
      <HistoryTests section={{ Enum.at(@group.sections, 3) }} />
    </div>
    """
  end
end
