defmodule HealthBoard.Contexts.Demographic.HealthRegionsResidentYearlyBirths do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.HealthRegionResidentYearlyBirths
  alias HealthBoard.Repo

  @spec get_summary_by(atom(), keyword()) :: integer()
  def get_summary_by(summary_field, filters) do
    HealthRegionResidentYearlyBirths
    |> filter_query(filters)
    |> select([hrryb], field(hrryb, ^summary_field))
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec get_total_by(keyword()) :: integer()
  def get_total_by(filters) do
    HealthRegionResidentYearlyBirths
    |> filter_query(filters)
    |> select([hrryb], hrryb.births)
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:health_region_id, health_region_id} ->
          where(query, [hrryb], hrryb.health_region_id == ^health_region_id)

        {:health_regions_ids, health_regions_ids} ->
          where(query, [hrryb], hrryb.health_region_id in ^health_regions_ids)

        {:year, year} ->
          where(query, [hrryb], hrryb.year == ^year)

        {:year_period, [from, to]} ->
          where(query, [hrryb], hrryb.year >= ^from and hrryb.year <= ^to)

        _unknown ->
          query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
