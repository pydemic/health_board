defmodule HealthBoard.Contexts.Demographic.RegionsSourceYearlyBirths do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.RegionSourceYearlyBirths
  alias HealthBoard.Repo

  @spec get_summary_by(atom(), keyword()) :: integer()
  def get_summary_by(summary_field, filters) do
    RegionSourceYearlyBirths
    |> filter_query(filters)
    |> select([rryb], field(rryb, ^summary_field))
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec get_total_by(keyword()) :: integer()
  def get_total_by(filters) do
    RegionSourceYearlyBirths
    |> filter_query(filters)
    |> select([rryb], rryb.births)
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
        {:region_id, region_id} -> where(query, [rryb], rryb.region_id == ^region_id)
        {:regions_ids, regions_ids} -> where(query, [rryb], rryb.region_id in ^regions_ids)
        {:year, year} -> where(query, [rryb], rryb.year == ^year)
        {:year_period, [from, to]} -> where(query, [rryb], rryb.year >= ^from and rryb.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
