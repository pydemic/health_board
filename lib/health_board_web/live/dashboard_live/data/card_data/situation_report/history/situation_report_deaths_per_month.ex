defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportDeathsPerMonth do
  @first_case_year 2020
  @first_case_month 2

  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &fetch/1, data, {:chart, :line}}, 1_000)

    %{
      filters: %{
        location: data.location_name
      }
    }
  end

  defp fetch(%{monthly_covid_reports: monthly_covid_reports} = data) do
    months = fetch_months(data)

    months
    |> Enum.map(&fetch_data(&1, monthly_covid_reports))
    |> wrap_result(months, data.section_card_id)
  end

  defp fetch_months(data) do
    %{date: %{year: to_year, month: to_month}} = data

    for month <- 1..12, year <- @first_case_year..to_year do
      if (year == @first_case_year and month < @first_case_month) or (year == to_year and month > to_month) do
        nil
      else
        {year, month}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  defp fetch_data({year, month}, monthly_covid_reports) do
    Enum.find_value(monthly_covid_reports, 0, &if(&1.year == year and &1.month == month, do: &1.deaths))
  end

  defp wrap_result(data, months, id) do
    %{
      id: id,
      data: data,
      labels: Enum.map(months, fn {year, month} -> "#{year}-#{month}" end),
      label: "Óbitos"
    }
  end
end
