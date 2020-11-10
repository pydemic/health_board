defmodule HealthBoard.Contexts.Demographic.CountriesPopulation do
  import Ecto.Query, only: [order_by: 3, select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.CountryPopulation
  alias HealthBoard.Repo

  @spec get_by(keyword()) :: %CountryPopulation{}
  def get_by(filters) do
    CountryPopulation
    |> filter_query(filters)
    |> Repo.one()
  end

  @spec get_summary_by(atom(), keyword()) :: integer()
  def get_summary_by(summary_field, filters) do
    CountryPopulation
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
    CountryPopulation
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
    CountryPopulation
    |> filter_query(filters)
    |> select([cp], field(cp, ^summary_field))
    |> sort_query(filters)
    |> Repo.all()
  end

  @spec list_total_by(keyword()) :: list(integer())
  def list_total_by(filters) do
    CountryPopulation
    |> filter_query(filters)
    |> select([cp], cp.male + cp.female)
    |> sort_query(filters)
    |> Repo.all()
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:country_id, country_id} -> where(query, [cp], cp.country_id == ^country_id)
        {:countries_ids, countries_ids} -> where(query, [cp], cp.country_id in ^countries_ids)
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
      :country_id -> order_by(query, [cp], asc: cp.country_id)
      :year -> order_by(query, [cp], asc: cp.year)
    end
  end
end
