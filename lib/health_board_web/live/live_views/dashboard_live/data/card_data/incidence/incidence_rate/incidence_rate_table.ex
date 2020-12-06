defmodule HealthBoardWeb.DashboardLive.CardData.IncidenceRateTable do
  alias HealthBoard.Contexts

  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = card_data) do
    with {:ok, morbidity_contexts} <- fetch_morbidity_contexts(filters) do
      %{
        locations_yearly_morbidities: yearly_morbidities,
        locations_yearly_populations: yearly_populations,
        children_locations: locations
      } = data

      headers = headers(morbidity_contexts)
      # lines = Enum.map(locations, &line(&1, yearly_populations, yearly_morbidities, headers))
    end

    card_data
  end

  defp headers(morbidity_contexts) do
    morbidity_contexts
    |> Enum.map(&Contexts.morbidity_name/1)
    |> Enum.sort()
  end

  defp fetch_morbidity_contexts(filters) do
    case Map.get(filters, "morbidity_contexts") do
      nil -> {:error, :morbidity_contexts_missing}
      morbidity_contexts -> {:ok, morbidity_contexts}
    end
  end
end
