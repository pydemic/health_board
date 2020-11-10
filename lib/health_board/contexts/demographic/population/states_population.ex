defmodule HealthBoard.Contexts.Demographic.StatesPopulation do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.StatePopulation
  alias HealthBoard.Repo

  @spec get_by(map()) :: %StatePopulation{}
  def get_by(filters) do
    StatePopulation
    |> filter_query(filters)
    |> Repo.one()
  end

  @spec get_total_by(map()) :: integer()
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

  @spec list_total_by(map()) :: list(integer())
  def list_total_by(filters) do
    StatePopulation
    |> filter_query(filters)
    |> select([sp], %{total: sp.male + sp.female, year: sp.year})
    |> Repo.all()
    |> Enum.sort(&(&1.year <= &2.year))
    |> Enum.map(& &1.total)
  end

  @spec create(map()) :: {:ok, %StatePopulation{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %StatePopulation{}
    |> StatePopulation.changeset(attrs)
    |> Repo.insert()
  end

  defp filter_query(query, filters) when is_map(filters) do
    filter_query(query, Map.to_list(filters))
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:state_id, state_id} -> where(query, [sp], sp.state_id == ^state_id)
        {:year, year} -> where(query, [sp], sp.year == ^year)
        {:year_period, [from, to]} -> where(query, [sp], sp.year >= ^from and sp.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
