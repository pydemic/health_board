defmodule HealthBoardWeb.DashboardLive.CardData.CrudeBirthRatePerYear do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :line}}, 1_000)

    %{
      filters: %{
        from_year: data.births_from_year,
        to_year: data.births_to_year,
        location: data.location_name
      }
    }
  end

  defp do_fetch(data) do
    years = fetch_years(data)
    %{yearly_births: births, yearly_population: populations} = data

    years
    |> Enum.map(&fetch_data(&1, births, populations))
    |> wrap_result(years, data.section_card_id)
  end

  defp fetch_years(data) do
    data.births_from_year
    |> Range.new(data.births_to_year)
    |> Enum.to_list()
  end

  defp fetch_data(year, births, populations) do
    births = Enum.find_value(births, 0, &if(&1.year == year, do: &1.total))
    population = Enum.find_value(populations, 0, &if(&1.year == year, do: &1.total))

    if births > 0 and population > 0 do
      births * 100 / population
    else
      0.0
    end
  end

  defp wrap_result(data, years, id) do
    %{
      id: id,
      data: data,
      labels: years,
      label: "Taxa bruta de natalidade"
    }
  end
end
