defmodule HealthBoardWeb.DashboardLive.GroupData.CoronavirusIncidenceGroup do
  alias HealthBoardWeb.DashboardLive.SectionData

  @spec fetch(pid, map, map) :: nil
  def fetch(pid, group, data) do
    Enum.each(group.sections, &SectionData.request_to_fetch(pid, &1, data))

    nil
  end
end
