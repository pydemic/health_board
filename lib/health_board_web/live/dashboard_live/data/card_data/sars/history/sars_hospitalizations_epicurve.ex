defmodule HealthBoardWeb.DashboardLive.CardData.SarsHospitalizationsEpicurve do
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
      },
      last_record_date: data.last_record_date
    }
  end

  defp do_fetch(data) do
    %{
      section_card_id: id,
      date: to_date,
      daily_hospitalizations: daily_hospitalizations
    } = data

    dates = Date.range(@first_case_date, to_date)
    hospitalizations_per_day = Enum.map(dates, &fetch_hospitalizations(daily_hospitalizations, &1))
    trend = Math.moving_average(hospitalizations_per_day)

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
          label: "Internações",
          backgroundColor: background_color,
          borderColor: border_color,
          pointRadius: 2,
          borderWidth: 3,
          fill: false,
          data: hospitalizations_per_day
        }
      ]
    }
  end

  defp fetch_hospitalizations(day_incidence, date) do
    Enum.find_value(day_incidence, 0, &if(Date.compare(date, &1.date) == :eq, do: &1.confirmed))
  end
end
