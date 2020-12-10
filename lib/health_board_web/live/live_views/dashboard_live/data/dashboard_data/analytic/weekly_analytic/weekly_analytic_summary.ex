defmodule HealthBoardWeb.DashboardLive.SectionData.WeeklyAnalyticSummary do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [
    :index,
    :year,
    :location_id,
    :data_periods_per_context,
    :yearly_deaths_per_context,
    :yearly_morbidities_per_context
  ]

  @data_keys [
    :params,
    :year,
    :location_name,
    :location_id,
    :data_periods_per_context,
    :yearly_deaths_per_context,
    :yearly_morbidities_per_context
  ]

  @spec fetch(pid, map, map) :: list(map) | nil
  def fetch(pid, section, %{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @changes_keys) do
      data = Map.take(data, @data_keys)

      section.cards
      |> Enum.map(&fetch_card(pid, &1, data))
      |> Enum.sort(&(&1.ratio >= &2.ratio))
      |> Enum.sort(&higher_severity?(&1.severity, &2.severity))
      |> Enum.map(& &1.index)
    else
      nil
    end
  end

  defp fetch_card(pid, %{index: index} = section_card, data) do
    %{
      result: %{
        overall_severity: severity,
        deaths: %{average: average_deaths, total: deaths},
        morbidity: %{average: average_cases, total: cases}
      }
    } = CardData.fetch(pid, section_card, data)

    %{index: index, severity: severity, ratio: div(ratio(deaths, average_deaths) + ratio(cases, average_cases), 2)}
  end

  defp ratio(_cases, 0), do: 0
  defp ratio(cases, average), do: round(cases * 100 / average)

  defp higher_severity?(:above_average, _severity), do: true
  defp higher_severity?(_severity, :above_average), do: false
  defp higher_severity?(:on_average, _severity), do: true
  defp higher_severity?(_severity, :on_average), do: false
  defp higher_severity?(:below_average, _severity), do: true
  defp higher_severity?(_severity, :below_average), do: false
  defp higher_severity?(_severity1, _severity2), do: true
end
