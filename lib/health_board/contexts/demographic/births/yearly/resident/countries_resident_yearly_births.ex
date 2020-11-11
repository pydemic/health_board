defmodule HealthBoard.Contexts.Demographic.CountriesResidentYearlyBirths do
  import Ecto.Query, only: [order_by: 3, select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.CountryResidentYearlyBirths
  alias HealthBoard.Repo

  @spec get_by(keyword()) :: %CountryResidentYearlyBirths{}
  def get_by(filters) do
    CountryResidentYearlyBirths
    |> filter_query(filters)
    |> Repo.one()
  end

  @spec get_summary_by(atom(), keyword()) :: integer()
  def get_summary_by(summary_field, filters) do
    CountryResidentYearlyBirths
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
    CountryResidentYearlyBirths
    |> filter_query(filters)
    |> select([t], t.births)
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec list_summary_by(atom(), keyword()) :: list(integer())
  def list_summary_by(summary_field, filters) do
    CountryResidentYearlyBirths
    |> filter_query(filters)
    |> select([t], field(t, ^summary_field))
    |> sort_query(filters)
    |> Repo.all()
  end

  @spec list_total_by(keyword()) :: list(integer())
  def list_total_by(filters) do
    CountryResidentYearlyBirths
    |> filter_query(filters)
    |> select([t], t.births)
    |> sort_query(filters)
    |> Repo.all()
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:country_id, country_id} -> where(query, [t], t.country_id == ^country_id)
        {:countries_ids, countries_ids} -> where(query, [t], t.country_id in ^countries_ids)
        {:year, year} -> where(query, [t], t.year == ^year)
        {:year_period, [from, to]} -> where(query, [t], t.year >= ^from and t.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end

  defp sort_query(query, filters) do
    case Keyword.get(filters, :sort_by, :year) do
      :country_id -> order_by(query, [t], asc: t.country_id)
      :year -> order_by(query, [t], asc: t.year)
    end
  end
end
