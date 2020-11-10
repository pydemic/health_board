defmodule HealthBoard.Contexts.Demographic.CitiesSourceYearlyBirths do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.CitySourceYearlyBirths
  alias HealthBoard.Repo

  @spec get_summary_by(atom(), keyword()) :: integer()
  def get_summary_by(summary_field, filters) do
    CitySourceYearlyBirths
    |> filter_query(filters)
    |> select([cryb], field(cryb, ^summary_field))
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec get_total_by(keyword()) :: integer()
  def get_total_by(filters) do
    CitySourceYearlyBirths
    |> filter_query(filters)
    |> select([cryb], cryb.births)
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
        {:city_id, city_id} -> where(query, [cryb], cryb.city_id == ^city_id)
        {:cities_ids, cities_ids} -> where(query, [cryb], cryb.city_id in ^cities_ids)
        {:year, year} -> where(query, [cryb], cryb.year == ^year)
        {:year_period, [from, to]} -> where(query, [cryb], cryb.year >= ^from and cryb.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
