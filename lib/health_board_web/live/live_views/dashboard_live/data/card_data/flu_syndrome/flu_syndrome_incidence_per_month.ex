defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromeIncidencePerMonth do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &fetch/1, data, {:chart, :line}}, 1_000)

    %{
      filters: %{
        from_year: data.from_year,
        to_year: data.to_year,
        location: data.location_name
      }
    }
  end

  defp fetch(%{monthly_cases: cases} = data) do
    months = fetch_months(data)

    months
    |> Enum.map(&fetch_data(&1, cases))
    |> wrap_result(months, data.section_card_id)
  end

  defp fetch_months(data) do
    %{from_date: %{year: from_year, month: from_month}, to_date: %{year: to_year, month: to_month}} = data

    for month <- 1..12, year <- from_year..to_year do
      if (year == from_year and month < from_month) or (year == to_year and month > to_month) do
        nil
      else
        {year, month}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  defp fetch_data({year, month}, cases) do
    Enum.find_value(cases, 0, &if(&1.year == year and &1.month == month, do: &1.confirmed))
  end

  defp wrap_result(data, months, id) do
    %{
      id: id,
      data: data,
      labels: Enum.map(months, fn {year, month} -> "#{year}-#{month}" end),
      label: "Incidência"
    }
  end
end
