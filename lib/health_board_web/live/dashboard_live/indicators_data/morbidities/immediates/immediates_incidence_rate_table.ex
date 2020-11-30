defmodule HealthBoardWeb.DashboardLive.IndicatorsData.ImmediatesIncidenceRateTable do
  alias HealthBoardWeb.DashboardLive.IndicatorsData
  alias HealthBoardWeb.Helpers.Humanize

  @cases IndicatorsData.MorbidityIncidence
  @population IndicatorsData.Population

  @columns [
    10000,
    10100,
    10200,
    10800,
    10700,
    10300,
    10500,
    10600,
    10400,
    10900
  ]

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :analytic)
    |> IndicatorsData.CommonData.fetch_year(2020)
    |> IndicatorsData.CommonData.fetch_locations()
    |> IndicatorsData.put(:modifiers, :order_by, asc: :location_id)
    |> IndicatorsData.exec_and_put(:extra, :populations, &@population.list_populations/1)
    |> IndicatorsData.exec_and_put(:extra, :cases, &@cases.list_cases/1)
    |> IndicatorsData.exec_and_put(:data, :headers, &get_headers/1)
    |> IndicatorsData.exec_and_put(:data, :ranges, &get_ranges/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
  end

  defp get_headers(_indicators_data) do
    [
      "Botulismo",
      "Chikungunya",
      "Cólera",
      "Febre Amarela",
      "Febre Maculosa",
      "Hantavirus",
      "Malária",
      "Peste",
      "Raiva Humana",
      "Zika"
    ]
  end

  defp get_result(indicators_data) do
    %{data: %{ranges: ranges}, extra: %{cases: cases, locations: locations, populations: populations}} = indicators_data
    cases = Enum.filter(cases, &(rem(&1.context, 2) == 0))

    locations
    |> Enum.map(&get_line(&1, cases, populations, ranges))
    |> Enum.sort(&(&1.name <= &2.name))
  end

  defp get_values_per_column(context, cases, populations) do
    cases = Enum.filter(cases, &(&1.context == context))
    Enum.map(cases, &get_column_values(&1, populations))
  end

  defp get_column_values(%{cases: cases, location_id: location_id}, populations) do
    population = Enum.find_value(populations, 0, &if(&1.location_id == location_id, do: &1.total, else: nil))

    if population != 0 do
      cases * 100_000 / population
    else
      0.0
    end
  end

  defp get_line(%{id: location_id, name: name}, cases, populations, ranges) do
    cases = Enum.filter(cases, &(&1.location_id == location_id))
    population = Enum.find_value(populations, 0, &if(&1.location_id == location_id, do: &1.total, else: nil))
    cells = Enum.map(Enum.zip(@columns, ranges), &get_cell(&1, cases, population))
    %{name: name, cells: cells}
  end

  defp get_cell({context, ranges}, cases, population) do
    cases = Enum.find_value(cases, 0, &if(&1.context == context, do: &1.cases, else: nil))

    value =
      if population != 0 do
        cases * 100_000 / population
      else
        0.0
      end

    %{
      value: Humanize.number(value, fractional_digits: 2),
      color: Enum.find(ranges, %{color: "#cccccc"}, &on_boundary?(value, &1))
    }
  end

  defp on_boundary?(value, boundary) do
    case boundary do
      %{from: nil, to: to} -> value <= to
      %{from: from, to: nil} -> value >= from
      %{from: from, to: to} -> value >= from and value <= to
    end
  end

  defp get_ranges(%{extra: %{cases: cases, populations: populations}}) do
    cases = Enum.filter(cases, &(rem(&1.context, 2) == 0))
    values_per_column = Enum.map(@columns, &get_values_per_column(&1, cases, populations))
    Enum.map(values_per_column, &do_get_ranges/1)
  end

  defp do_get_ranges(data) do
    {q0, q1, q2, q3} =
      try do
        {
          0.0,
          Statistics.percentile(data, 25),
          Statistics.percentile(data, 50),
          Statistics.percentile(data, 75)
        }
      rescue
        _error -> {0.0, 0.0, 0.0, 0.0}
      end

    [
      %{from: nil, to: q0, color: "0"},
      %{from: q0, to: q1, color: "1"},
      %{from: q1, to: q2, color: "2"},
      %{from: q2, to: q3, color: "3"},
      %{from: q3, to: nil, color: "4"}
    ]
    |> Enum.reject(
      &(&1.from == &1.to or (is_nil(&1.from) == false and &1.from > &1.to) or (&1.from == 0.0 and &1.to == 0.0) or
          (&1.from == 0.0 and is_nil(&1.to)))
    )
  end
end
