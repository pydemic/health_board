defmodule HealthBoardWeb.DashboardLive.CardData.DeathRatePerYear do
  alias HealthBoard.Contexts

  @spec fetch(map()) :: map()
  def fetch(%{filters: filters} = card_data) do
    send(card_data.root_pid, {:exec_and_emit, &do_fetch/1, card_data, {:chart, :multiline}})

    card_data
    |> Map.put(:view_data, %{event_pushed: true})
    |> put_in([:filters, :morbidity_contexts], Enum.map(filters.morbidity_contexts, &Contexts.morbidity_name(&1)))
  end

  defp do_fetch(%{id: id, data: data, filters: filters}) do
    contexts = filters.morbidity_contexts
    years = fetch_years(filters)

    %{yearly_deaths: yearly_cases, yearly_populations: yearly_populations} = data

    yearly_populations = Enum.group_by(yearly_populations, & &1.year, & &1.total)

    yearly_cases
    |> Enum.filter(&(&1.context in contexts))
    |> Enum.group_by(& &1.context, fn %{total: total, year: year} -> %{total: total, year: year} end)
    |> Enum.map(&fetch_dataset(&1, yearly_populations, years))
    |> wrap_result(years, id)
  end

  defp wrap_result(datasets, years, id) do
    %{
      id: id,
      datasets: datasets,
      labels: years
    }
  end

  defp fetch_years(filters) do
    filters.from_year
    |> Range.new(filters.to_year)
    |> Enum.to_list()
  end

  defp fetch_dataset({context, context_cases}, yearly_populations, years) do
    yearly_cases = Enum.group_by(context_cases, & &1.year, & &1.total)

    %{
      label: Contexts.morbidity_name(context) || "N/A",
      data: Enum.map(years, &fetch_data(Map.get(yearly_cases, &1), Map.get(yearly_populations, &1)))
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
