defmodule HealthBoardWeb.DashboardLive.CardData.DeathRatePerYear do
  alias HealthBoard.Contexts

  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :multiline}}, 1_000)

    %{
      filters: %{
        from_year: data.from_year,
        to_year: data.to_year,
        location: data.location_name,
        morbidity_contexts: Enum.map(data.morbidity_contexts, &Contexts.morbidity_name/1)
      }
    }
  end

  defp do_fetch(data) do
    contexts = data.morbidity_contexts
    years = fetch_years(data)

    %{yearly_deaths_per_context: cases, yearly_population: populations} = data

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
      cases * 100 / population
    else
      0.0
    end
  end

  defp fetch_data(_cases, _population) do
    0.0
  end
end
