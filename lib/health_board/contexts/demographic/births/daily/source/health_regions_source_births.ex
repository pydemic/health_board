defmodule HealthBoard.Contexts.Demographic.HealthRegionsSourceBirths do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.HealthRegionSourceBirths
  alias HealthBoard.Repo

  @spec get_summary_by(atom(), keyword()) :: integer()
  def get_summary_by(summary_field, filters) do
    HealthRegionSourceBirths
    |> filter_query(filters)
    |> select([t], field(t, ^summary_field))
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec get_total_by(keyword()) :: integer()
  def get_total_by(filters) do
    HealthRegionSourceBirths
    |> filter_query(filters)
    |> select([t], t.births)
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
        {:health_region_id, id} -> where(query, [t], t.health_region_id == ^id)
        {:health_regions_ids, ids} -> where(query, [t], t.health_region_id in ^ids)
        {:week, week} -> where(query, [t], t.week == ^week)
        {:week_period, [from, to]} -> where(query, [t], t.week >= ^from and t.week <= ^to)
        {:date, date} -> where(query, [t], t.date == ^date)
        {:date_period, [from, to]} -> where(query, [t], t.date >= ^from and t.date <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
