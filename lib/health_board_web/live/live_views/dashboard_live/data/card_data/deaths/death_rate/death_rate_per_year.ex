defmodule HealthBoardWeb.DashboardLive.CardData.DeathRatePerYear do
  alias HealthBoard.Contexts

  @spec fetch(map()) :: map()
  def fetch(card_data) do
    send(self(), {:exec_and_emit, &do_fetch/1, card_data, {:chart, :multiline}})
    Map.put(card_data, :view_data, %{event_pushed?: true})
  end

  defp do_fetch(%{id: id, data: data, filters: filters}) do
    with {:ok, morbidity_contexts} <- fetch_morbidity_contexts(filters) do
      years = fetch_years(filters)

      %{yearly_deaths: yearly_deaths, yearly_populations: yearly_populations} = data

      yearly_populations = Enum.group_by(yearly_populations, & &1.year, & &1.total)

      yearly_deaths
      |> Enum.filter(&(&1.context in morbidity_contexts))
      |> Enum.group_by(& &1.context, fn %{total: total, year: year} -> %{total: total, year: year} end)
      |> Enum.map(&fetch_dataset(&1, yearly_populations, years))
      |> wrap_result(years, id)
    end
  rescue
    error -> {:error, error}
  end

  defp wrap_result(datasets, years, id) do
    {
      :ok,
      %{
        id: id,
        datasets: datasets,
        labels: years
      }
    }
  end

  defp fetch_morbidity_contexts(filters) do
    case Map.get(filters, "morbidity_contexts") do
      nil -> {:error, :morbidity_contexts_missing}
      morbidity_contexts -> {:ok, morbidity_contexts}
    end
  end

  defp fetch_years(filters) do
    filters
    |> Map.get("from_year", 2000)
    |> Range.new(Map.get_lazy(filters, "to_year", fn -> Date.utc_today().year end))
    |> Enum.to_list()
  end

  defp fetch_dataset({context, context_deaths}, yearly_populations, years) do
    yearly_deaths = Enum.group_by(context_deaths, & &1.year, & &1.total)

    %{
      label: Contexts.morbidity_name(context) || "N/A",
      data: Enum.map(years, &fetch_data(Map.get(yearly_deaths, &1), Map.get(yearly_populations, &1)))
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
