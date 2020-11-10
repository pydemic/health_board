defmodule HealthBoard.Contexts.Demographic.CitiesPopulation do
  import Ecto.Query, only: [order_by: 3, select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.CityPopulation
  alias HealthBoard.Repo

  @spec get_by(keyword()) :: %CityPopulation{}
  def get_by(filters) do
    CityPopulation
    |> filter_query(filters)
    |> Repo.one()
  end

  @spec get_summary_by(atom(), keyword()) :: integer()
  def get_summary_by(summary_field, filters) do
    CityPopulation
    |> filter_query(filters)
    |> select([cp], field(cp, ^summary_field))
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec get_total_by(keyword()) :: integer()
  def get_total_by(filters) do
    CityPopulation
    |> filter_query(filters)
    |> select([cp], cp.male + cp.female)
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec list_summary_by(atom(), keyword()) :: list(integer())
  def list_summary_by(summary_field, filters) do
    CityPopulation
    |> filter_query(filters)
    |> select([cp], field(cp, ^summary_field))
    |> sort_query(filters)
    |> Repo.all()
  end

  @spec list_total_by(keyword()) :: list(integer())
  def list_total_by(filters) do
    CityPopulation
    |> filter_query(filters)
    |> select([cp], cp.male + cp.female)
    |> sort_query(filters)
    |> Repo.all()
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:city_id, city_id} -> where(query, [cp], cp.city_id == ^city_id)
        {:cities_ids, cities_ids} -> where(query, [cp], cp.city_id in ^cities_ids)
        {:year, year} -> where(query, [cp], cp.year == ^year)
        {:year_period, [from, to]} -> where(query, [cp], cp.year >= ^from and cp.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end

  defp sort_query(query, filters) do
    case Keyword.get(filters, :sort_by, :year) do
      :city_id -> order_by(query, [cp], asc: cp.city_id)
      :year -> order_by(query, [cp], asc: cp.year)
    end
  end
end
