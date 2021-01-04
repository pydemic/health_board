defmodule HealthBoardWeb.DashboardLive.CardData.SarsDeathsPerWeek do
  @first_case_year 2020
  @first_case_week 9

  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &fetch/1, data, {:chart, :line}}, 1_000)

    %{
      filters: %{
        location: data.location_name
      }
    }
  end

  defp fetch(%{weekly_deaths: weekly_deaths} = data) do
    months = fetch_months(data)

    months
    |> Enum.map(&fetch_data(&1, weekly_deaths))
    |> wrap_result(months, data.section_card_id)
  end

  defp fetch_months(data) do
    %{date: to_date} = data

    {to_year, to_week} = :calendar.iso_week_number(Date.to_erl(to_date))

    for week <- 1..53, year <- @first_case_year..to_year do
      if (year == @first_case_year and week < @first_case_week) or (year == to_year and week > to_week) do
        nil
      else
        {year, week}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  defp fetch_data({year, week}, weekly_deaths) do
    Enum.find_value(weekly_deaths, 0, &if(&1.year == year and &1.week == week, do: &1.confirmed))
  end

  defp wrap_result(data, weeks, id) do
    %{
      id: id,
      data: data,
      labels: Enum.map(weeks, fn {year, week} -> "#{year}-#{week}" end),
      label: "Incidência"
    }
  end
end