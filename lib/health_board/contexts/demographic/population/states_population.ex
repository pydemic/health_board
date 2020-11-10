defmodule HealthBoard.Contexts.Demographic.StatesPopulation do
  import Ecto.Query, only: [order_by: 3, select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.StatePopulation
  alias HealthBoard.Repo

  @spec get_by(keyword()) :: %StatePopulation{}
  def get_by(filters) do
    StatePopulation
    |> filter_query(filters)
    |> Repo.one()
  end

  @spec get_summary_by(atom(), keyword()) :: integer()
  def get_summary_by(summary_field, filters) do
    StatePopulation
    |> filter_query(filters)
    |> select([sp], field(sp, ^summary_field))
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec get_total_by(keyword()) :: integer()
  def get_total_by(filters) do
    StatePopulation
    |> filter_query(filters)
    |> select([sp], sp.male + sp.female)
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec list_summary_by(atom(), keyword()) :: list(integer())
  def list_summary_by(summary_field, filters) do
    StatePopulation
    |> filter_query(filters)
    |> select([sp], field(sp, ^summary_field))
    |> sort_query(filters)
    |> Repo.all()
  end

  @spec list_total_by(keyword()) :: list(integer())
  def list_total_by(filters) do
    StatePopulation
    |> filter_query(filters)
    |> select([sp], sp.male + sp.female)
    |> sort_query(filters)
    |> Repo.all()
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:state_id, state_id} -> where(query, [sp], sp.state_id == ^state_id)
        {:states_ids, states_ids} -> where(query, [sp], sp.state_id == ^states_ids)
        {:year, year} -> where(query, [sp], sp.year == ^year)
        {:year_period, [from, to]} -> where(query, [sp], sp.year >= ^from and sp.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end

  defp sort_query(query, filters) do
    case Keyword.get(filters, :sort_by, :year) do
      :state_id -> order_by(query, [sp], asc: sp.state_id)
      :year -> order_by(query, [sp], asc: sp.year)
    end
  end
end
