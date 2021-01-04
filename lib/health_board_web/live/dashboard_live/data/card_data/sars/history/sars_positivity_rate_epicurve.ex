defmodule HealthBoardWeb.DashboardLive.CardData.SarsPositivityRateEpicurve do
  alias HealthBoardWeb.Helpers.{Colors, Math}

  @first_case_date Date.from_erl!({2020, 2, 26})

  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :combo}}, 1_000)

    %{
      filters: %{
        from_date: @first_case_date,
        to_date: data.date,
        location: data.location_name
      }
    }
  end

  defp do_fetch(data) do
    %{
      section_card_id: id,
      date: to_date,
      daily_incidence: daily_incidence
    } = data

    dates = Date.range(@first_case_date, to_date)
    rates = Enum.map(dates, &fetch_rate(daily_incidence, &1))
    trend = Math.moving_average(rates)

    {background_color, border_color} = Colors.blue_with_border()

    %{
      id: id,
      labels: Enum.to_list(dates),
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
          label: "Taxa de positividade",
          backgroundColor: background_color,
          borderColor: border_color,
          pointRadius: 2,
          borderWidth: 3,
          fill: false,
          data: rates
        }
      ]
    }
  end

  defp fetch_rate(day_incidence, date) do
    Enum.find_value(
      day_incidence,
      0,
      &if(Date.compare(date, &1.date) == :eq, do: Math.positivity_rate(&1.confirmed, &1.samples))
    )
  end
end
