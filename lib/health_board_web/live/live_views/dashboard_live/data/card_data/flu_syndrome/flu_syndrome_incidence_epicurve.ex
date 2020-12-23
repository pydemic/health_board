defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromeIncidenceEpicurve do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :combo}}, 1_000)

    %{
      filters: %{
        from_date: data.from_date,
        to_date: data.to_date,
        location: data.location_name
      }
    }
  end

  defp do_fetch(data) do
    %{
      section_card_id: id,
      from_date: from_date,
      to_date: to_date,
      daily_cases: daily_cases
    } = data

    dates = fetch_dates(from_date, to_date)
    incidences = Enum.map(dates, &fetch_incidence(daily_cases, &1))
    trend = fetch_moving_average(incidences)

    %{
      id: id,
      labels: dates,
      labelString: "Data",
      datasets: [
        %{
          type: "line",
          label: "Tendência",
          backgroundColor: "#000",
          borderColor: "#000",
          borderWidth: 2,
          pointRadius: 1,
          fill: false,
          data: trend
        },
        %{
          type: "bar",
          label: "Incidência",
          backgroundColor: "#4aac63",
          borderColor: "#4aac63",
          pointRadius: 2,
          borderWidth: 3,
          fill: false,
          data: incidences
        }
      ]
    }
  end

  defp fetch_dates(from, to, dates \\ []) do
    if Date.compare(from, to) == :eq do
      [from | dates]
    else
      fetch_dates(from, Date.add(to, -1), [to | dates])
    end
  end

  defp fetch_incidence(day_cases, date) do
    Enum.find_value(day_cases, 0, &if(Date.compare(date, &1.date) == :eq, do: &1.confirmed))
  end

  defp fetch_moving_average(incidences) do
    incidences
    |> displace_by(7)
    |> Enum.zip()
    |> Enum.map(&calculate_moving_average/1)
  end

  defp displace_by(list, amount, displaced_lists \\ nil) do
    if amount == 0 do
      displaced_lists
    else
      if displaced_lists == nil do
        displace_by(list, amount - 1, [list])
      else
        [list | _displaced_lists] = displaced_lists
        displace_by(list, amount - 1, [[nil | list] | displaced_lists])
      end
    end
  end

  defp calculate_moving_average(displaced_data) do
    displaced_data
    |> Tuple.to_list()
    |> Enum.reverse()
    |> Enum.reject(&is_nil/1)
    |> calculate_average()
  end

  defp calculate_average(data) do
    if Enum.any?(data) do
      Enum.sum(data) / length(data)
    else
      0.0
    end
  end
end
