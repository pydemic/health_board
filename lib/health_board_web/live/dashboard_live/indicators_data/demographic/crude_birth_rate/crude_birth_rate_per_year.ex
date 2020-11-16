defmodule HealthBoardWeb.DashboardLive.IndicatorsData.CrudeBirthRatePerYear do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @births IndicatorsData.Births
  @population IndicatorsData.Population

  @default_birth_year_period [2000, 2018]

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year_period()
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.put(:modifiers, :order_by, asc: :year)
    |> IndicatorsData.exec_and_put(:extra, :populations, &@population.list_populations/1)
    |> IndicatorsData.CommonData.fetch_year_period(&subtract_years_by_one/1)
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@births.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :births, &@births.list_births/1)
    |> IndicatorsData.exec_and_put(:extra, :labels, &get_labels/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :line)
  end

  defp subtract_years_by_one(year_period) do
    if is_list(year_period) do
      Enum.map(year_period, &@births.subtract_year_by_one/1)
    else
      @default_birth_year_period
    end
  end

  defp get_labels(%{extra: %{year_period: [from, to]}}) do
    from
    |> Range.new(to)
    |> Enum.to_list()
  end

  defp get_result(%{extra: %{births: births, labels: labels, populations: populations}}) do
    Enum.map(labels, &get_label_result(&1, births, populations))
  end

  defp get_label_result(year, births, populations) do
    births = Enum.find_value(births, 0, &if(&1.year == year, do: &1.births, else: nil))
    population = Enum.find_value(populations, 0, &if(&1.year == year, do: &1.total, else: nil))

    %{
      birth: births,
      population: population,
      value: if(population != 0, do: births * 1_000 / population, else: 0.0),
      year: year
    }
  end
end
