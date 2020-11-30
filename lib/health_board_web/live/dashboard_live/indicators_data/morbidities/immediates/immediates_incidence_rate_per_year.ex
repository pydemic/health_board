defmodule HealthBoardWeb.DashboardLive.IndicatorsData.ImmediatesIncidenceRatePerYear do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @contexts [
    {10000, "Botulismo"},
    {10100, "Chikungunya"},
    {10200, "Cólera"},
    {10300, "Hantavirus"},
    {10400, "Raiva Humana"},
    {10500, "Malária"},
    {10600, "Peste"},
    {10700, "Febre Maculosa"},
    {10800, "Febre Amarela"},
    {10900, "Zika"}
  ]

  @cases IndicatorsData.MorbidityIncidence
  @population IndicatorsData.Population

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :analytic)
    |> IndicatorsData.CommonData.fetch_year_period()
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.put(:modifiers, :order_by, asc: :year)
    |> IndicatorsData.exec_and_put(:extra, :populations, &@population.list_populations/1)
    |> IndicatorsData.exec_and_put(:extra, :cases, &@cases.list_cases/1)
    |> IndicatorsData.exec_and_put(:extra, :labels, &get_labels/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :multiline)
  end

  defp get_labels(%{extra: %{year_period: [from, to]}}) do
    from
    |> Range.new(to)
    |> Enum.to_list()
  end

  defp get_result(%{extra: %{cases: cases, labels: labels, populations: populations}}) do
    cases =
      cases
      |> Enum.filter(&(rem(&1.context, 2) == 0))
      |> Enum.group_by(& &1.context)
      |> Enum.map(&get_dataset(&1, labels, populations))

    Enum.map(@contexts, &add_cases_into_context(&1, labels, cases))
  end

  defp add_cases_into_context({_context, context_name}, years, cases) do
    case Enum.find(cases, &(&1.label == context_name)) do
      nil -> %{label: context_name, data: Enum.map(years, fn _year -> 0.0 end)}
      cases -> cases
    end
  end

  defp get_dataset({context, cases}, years, populations) do
    %{
      label: get_context_name(context),
      data: Enum.map(years, &get_year_result(&1, cases, populations))
    }
  end

  defp get_context_name(context) do
    case context do
      10000 -> "Botulismo"
      10100 -> "Chikungunya"
      10200 -> "Cólera"
      10300 -> "Hantavirus"
      10400 -> "Raiva Humana"
      10500 -> "Malária"
      10600 -> "Peste"
      10700 -> "Febre Maculosa"
      10800 -> "Febre Amarela"
      10900 -> "Zika"
      _context -> "N/A"
    end
  end

  defp get_year_result(year, cases, populations) do
    cases = Enum.find_value(cases, 0, &if(&1.year == year, do: &1.cases, else: nil))
    population = Enum.find_value(populations, 0, &if(&1.year == year, do: &1.total, else: nil))

    if population != 0 do
      cases * 100_000 / population
    else
      0.0
    end
  end
end
