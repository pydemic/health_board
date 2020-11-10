defmodule HealthBoard.Contexts.Demographic.StatesSourceYearlyBirths do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.StateSourceYearlyBirths
  alias HealthBoard.Repo

  @spec get_summary_by(atom(), keyword()) :: integer()
  def get_summary_by(summary_field, filters) do
    StateSourceYearlyBirths
    |> filter_query(filters)
    |> select([sryb], field(sryb, ^summary_field))
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec get_total_by(keyword()) :: integer()
  def get_total_by(filters) do
    StateSourceYearlyBirths
    |> filter_query(filters)
    |> select([sryb], sryb.births)
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
        {:state_id, state_id} -> where(query, [sryb], sryb.state_id == ^state_id)
        {:states_ids, states_ids} -> where(query, [sryb], sryb.state_id in ^states_ids)
        {:year, year} -> where(query, [sryb], sryb.year == ^year)
        {:year_period, [from, to]} -> where(query, [sryb], sryb.year >= ^from and sryb.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
