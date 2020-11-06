defmodule HealthBoard.Contexts.Demographic.HealthRegionsPopulation do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.HealthRegionPopulation
  alias HealthBoard.Repo

  @spec get_by(map()) :: %HealthRegionPopulation{}
  def get_by(filters) do
    HealthRegionPopulation
    |> filter_query(filters)
    |> Repo.one()
  end

  @spec get_total_by(map()) :: integer()
  def get_total_by(filters) do
    HealthRegionPopulation
    |> filter_query(filters)
    |> select([hrp], hrp.male + hrp.female)
    |> Repo.one()
    |> case do
      nil -> 0
      value -> value
    end
  end

  @spec list_total_by(map()) :: list(integer())
  def list_total_by(filters) do
    HealthRegionPopulation
    |> filter_query(filters)
    |> select([hrp], %{total: hrp.male + hrp.female, year: hrp.year})
    |> Repo.all()
    |> Enum.sort(&(&1.year <= &2.year))
    |> Enum.map(& &1.total)
  end

  @spec create(map()) :: {:ok, %HealthRegionPopulation{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %HealthRegionPopulation{}
    |> HealthRegionPopulation.changeset(attrs)
    |> Repo.insert()
  end

  defp filter_query(query, filters) when is_map(filters) do
    filter_query(query, Map.to_list(filters))
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:health_region_id, health_region_id} -> where(query, [hrp], hrp.health_region_id == ^health_region_id)
        {:year, year} -> where(query, [hrp], hrp.year == ^year)
        {:year_period, [from, to]} -> where(query, [hrp], hrp.year >= ^from and hrp.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
