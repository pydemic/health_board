defmodule HealthBoard.Contexts.Demographic.RegionsPopulation do
  import Ecto.Query, only: [order_by: 3, select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.RegionPopulation
  alias HealthBoard.Repo

  @spec get_by(keyword()) :: %RegionPopulation{}
  def get_by(filters) do
    RegionPopulation
    |> filter_query(filters)
    |> Repo.one()
  end

  @spec get_summary_by(atom(), keyword()) :: integer()
  def get_summary_by(summary_field, filters) do
    RegionPopulation
    |> filter_query(filters)
    |> select([rp], field(rp, ^summary_field))
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec get_total_by(keyword()) :: integer()
  def get_total_by(filters) do
    RegionPopulation
    |> filter_query(filters)
    |> select([rp], rp.male + rp.female)
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec list_summary_by(atom(), keyword()) :: list(integer())
  def list_summary_by(summary_field, filters) do
    RegionPopulation
    |> filter_query(filters)
    |> select([rp], field(rp, ^summary_field))
    |> sort_query(filters)
    |> Repo.all()
  end

  @spec list_total_by(keyword()) :: list(integer())
  def list_total_by(filters) do
    RegionPopulation
    |> filter_query(filters)
    |> select([rp], rp.male + rp.female)
    |> sort_query(filters)
    |> Repo.all()
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:region_id, region_id} -> where(query, [rp], rp.region_id == ^region_id)
        {:regions_ids, regions_ids} -> where(query, [rp], rp.region_id in ^regions_ids)
        {:year, year} -> where(query, [rp], rp.year == ^year)
        {:year_period, [from, to]} -> where(query, [rp], rp.year >= ^from and rp.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end

  defp sort_query(query, filters) do
    case Keyword.get(filters, :sort_by, :year) do
      :region_id -> order_by(query, [rp], asc: rp.region_id)
      :year -> order_by(query, [rp], asc: rp.year)
    end
  end
end
