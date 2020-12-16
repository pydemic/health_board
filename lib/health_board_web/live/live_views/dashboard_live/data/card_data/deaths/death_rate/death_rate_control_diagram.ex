defmodule HealthBoardWeb.DashboardLive.CardData.DeathRateControlDiagram do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :combo}}, 1_000)

    %{
      filters: %{
        year: data.to_year,
        location: data.location_name,
        morbidity_context: data.morbidity_name
      }
    }
  end

  defp do_fetch(data) do
    %{
      section_card_id: id,
      from_year: from_year,
      to_year: to_year,
      deaths_data_period: data_period,
      weekly_deaths: weekly_cases,
      yearly_population: yearly_population
    } = data

    weeks = Enum.to_list(1..53)

    rates = fetch_rates(weekly_cases, yearly_population)

    {lower, middle, upper} = moving_average_boundaries(rates, weeks, data_period, from_year, to_year)

    rates = Enum.filter(rates, &(&1.year == to_year))

    %{
      id: id,
      labels: weeks,
      labelString: "Semana",
      datasets: [
        %{
          type: "line",
          label: "Coeficiente de mortalidade na semana",
          backgroundColor: "#445",
          borderColor: "#445",
          pointRadius: 2,
          borderWidth: 3,
          fill: false,
          data: Enum.map(weeks, &find_rate_from_week(rates, &1))
        },
        %{
          type: "line",
          label: "Limite inferior do canal endêmico",
          backgroundColor: "#6dac6d",
          borderColor: "#6dac6d",
          borderWidth: 2,
          pointRadius: 1,
          fill: false,
          data: lower
        },
        %{
          type: "line",
          label: "Limite superior do canal endêmico",
          backgroundColor: "#e47f7f",
          borderColor: "#e47f7f",
          borderWidth: 2,
          pointRadius: 1,
          fill: false,
          data: upper
        },
        %{
          type: "line",
          label: "Índice endêmico",
          backgroundColor: "#dbcb37",
          borderColor: "#dbcb37",
          borderWidth: 1,
          pointRadius: 0,
          fill: false,
          data: middle
        }
      ]
    }
  end

  defp fetch_rates(weekly_cases, yearly_populations) do
    population_per_year = Enum.group_by(yearly_populations, & &1.year, & &1.total)
    Enum.map(weekly_cases, &fetch_rate(&1, population_per_year))
  end

  defp fetch_rate(%{year: year, week: week, total: cases}, population_per_year) do
    [population] = Map.get(population_per_year, year, [0])

    if population > 0 and cases > 0 do
      %{year: year, week: week, cases: cases, rate: cases * 100 / population}
    else
      %{year: year, week: week, cases: cases, rate: 0.0}
    end
  end

  defp moving_average_boundaries(rates, weeks, data_period, from_year, to_year) do
    rates
    |> weekly_rates(weeks, data_period, from_year, to_year)
    |> displace_by(7)
    |> Enum.zip()
    |> Enum.map(&calculate_moving_average/1)
    |> Enum.group_by(& &1.week, & &1.average)
    |> Enum.map(&calculate_moving_average_quartile/1)
    |> Enum.reverse()
    |> Enum.reduce({[], [], []}, &ungroup_boundaries/2)
  end

  defp weekly_rates(rates, weeks, %{from_year: from_year, from_week: from_week}, default_from_year, to_year) do
    from_year = from_year || default_from_year

    for year <- from_year..to_year, week <- weeks do
      if year < from_year or (year == from_year and week < from_week) do
        nil
      else
        %{week: week, rate: rate} = Enum.find(rates, %{week: week, rate: 0.0}, &(&1.year == year and &1.week == week))
        %{week: week, rate: rate}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  defp displace_by(list, amount, displaced_lists \\ nil) do
    if amount == 0 do
      displaced_lists
    else
      if displaced_lists == nil do
        displace_by(list, amount - 1, [list])
      else
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

  defp calculate_average([%{week: week} | _tail] = data) do
    size = length(data)
    %{week: week, average: Enum.reduce(data, 0.0, &(&1.rate + &2)) / size}
  end

  defp calculate_moving_average_quartile({_week, moving_averages}) do
    {
      Statistics.percentile(moving_averages, 25),
      Statistics.percentile(moving_averages, 50),
      Statistics.percentile(moving_averages, 75)
    }
  end

  defp ungroup_boundaries({q1, q2, q3}, {l1, l2, l3}) do
    {
      [q1 | l1],
      [q2 | l2],
      [q3 | l3]
    }
  end

  defp find_rate_from_week(rates, week) do
    Enum.find_value(rates, 0.0, &if(&1.week == week, do: &1.rate, else: nil))
  end
end
