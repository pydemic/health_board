defmodule HealthBoard.Contexts.Demographic.HealthInstitutionsSourceYearlyBirths do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.HealthInstitutionSourceYearlyBirths
  alias HealthBoard.Repo

  @spec get_summary_by(atom(), keyword()) :: integer()
  def get_summary_by(summary_field, filters) do
    HealthInstitutionSourceYearlyBirths
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
    HealthInstitutionSourceYearlyBirths
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
        {:health_institution_id, id} -> where(query, [t], t.health_institution_id == ^id)
        {:health_institutions_ids, ids} -> where(query, [t], t.health_institution_id in ^ids)
        {:year, year} -> where(query, [t], t.year == ^year)
        {:year_period, [from, to]} -> where(query, [t], t.year >= ^from and t.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
