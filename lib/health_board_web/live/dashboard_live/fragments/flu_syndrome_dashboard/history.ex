defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.History do
  use Surface.Component

  alias __MODULE__.{HistoryHealthProfessionalIncidence, HistoryIncidence, HistoryTests}
  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <HistoryIncidence section={{ Enum.at(@group.sections, 0) }} />
      <HistoryHealthProfessionalIncidence section={{ Enum.at(@group.sections, 1) }} />
      <HistoryTests section={{ Enum.at(@group.sections, 2) }} />
    </div>
    """
  end
end
