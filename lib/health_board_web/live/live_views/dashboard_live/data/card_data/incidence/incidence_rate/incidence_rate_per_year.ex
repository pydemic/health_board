defmodule HealthBoardWeb.DashboardLive.CardData.IncidenceRatePerYear do
  alias HealthBoard.Contexts

  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    if Map.has_key?(data, :morbidity_contexts) do
      Process.send_after(pid, {:exec_and_emit, &fetch_many/1, data, {:chart, :multiline}}, 1_000)

      %{
        filters: %{
          from_year: data.from_year,
          to_year: data.to_year,
          location: data.location_name,
          morbidity_contexts: Enum.map(data.morbidity_contexts, &Contexts.morbidity_name/1)
        }
      }
    else
      Process.send_after(pid, {:exec_and_emit, &fetch_one/1, data, {:chart, :line}}, 1_000)

      %{
        filters: %{
          from_year: data.from_year,
          to_year: data.to_year,
          location: data.location_name,
          morbidity_context: data.morbidity_name
        }
      }
    end
  end

  defp fetch_one(data) do
    years = fetch_years(data)

    %{yearly_morbidity: cases, yearly_population: populations} = data

    years
    |> Enum.map(&fetch_one_data(&1, cases, populations))
    |> wrap_one_result(years, data.section_card_id)
  end

  defp fetch_one_data(year, cases, populations) do
    cases = Enum.find_value(cases, 0, &if(&1.year == year, do: &1.total))
    population = Enum.find_value(populations, 0, &if(&1.year == year, do: &1.total))

    if cases > 0 and population > 0 do
      cases * 100_000 / population
    else
      0.0
    end
  end

  defp wrap_one_result(data, years, id) do
    %{
      id: id,
      data: data,
      labels: years,
      label: "Coeficiente de incidência"
    }
  end

  defp fetch_many(data) do
    contexts = data.morbidity_contexts
    years = fetch_years(data)

    %{yearly_morbidities_per_context: cases, yearly_population: populations} = data

    populations_per_year = Enum.group_by(populations, & &1.year, & &1.total)

    cases
    |> Enum.filter(&(elem(&1, 0) in contexts))
    |> Enum.map(&fetch_dataset(&1, populations_per_year, years))
    |> wrap_result(years, data.section_card_id)
  end

  defp wrap_result(datasets, years, id) do
    %{
      id: id,
      datasets: datasets,
      labels: years
    }
  end

  defp fetch_years(data) do
    data.from_year
    |> Range.new(data.to_year)
    |> Enum.to_list()
  end

  defp fetch_dataset({context, context_cases}, populations, years) do
    cases = Enum.group_by(context_cases, & &1.year, & &1.total)

    %{
      label: Contexts.morbidity_name(context) || "N/A",
      data: Enum.map(years, &fetch_data(Map.get(cases, &1), Map.get(populations, &1)))
    }
  end

  defp fetch_data([cases], [population]) when is_integer(cases) and is_integer(population) do
    if population > 0 do
      cases * 100_000 / population
    else
      0.0
    end
  end

  defp fetch_data(_cases, _population) do
    0.0
  end
end
