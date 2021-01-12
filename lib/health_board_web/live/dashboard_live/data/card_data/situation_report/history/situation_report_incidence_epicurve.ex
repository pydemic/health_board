defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportIncidenceEpicurve do
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
      daily_covid_reports: daily_covid_reports
    } = data

    dates = Date.range(@first_case_date, to_date)
    incidences = Enum.map(dates, &fetch_covid_reports(daily_covid_reports, &1))
    trend = Math.moving_average(incidences)

    {background_color, border_color} = Colors.blue_with_border()

    %{
      id: id,
      labels: Enum.to_list(dates),
      labelString: "Data",
      datasets: [
        %{
          type: "line",
          label: "Tendência (Média móvel de 7 dias)",
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
          backgroundColor: background_color,
          borderColor: border_color,
          pointRadius: 2,
          borderWidth: 3,
          fill: false,
          data: incidences
        }
      ]
    }
  end

  defp fetch_covid_reports(day_covid_reports, date) do
    Enum.find_value(day_covid_reports, 0, &if(Date.compare(date, &1.date) == :eq, do: &1.cases))
  end
end
