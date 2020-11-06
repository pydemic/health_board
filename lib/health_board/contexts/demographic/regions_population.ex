defmodule HealthBoard.Contexts.Demographic.RegionsPopulation do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.RegionPopulation
  alias HealthBoard.Repo

  @spec get_by(map()) :: %RegionPopulation{}
  def get_by(filters) do
    RegionPopulation
    |> filter_query(filters)
    |> Repo.one()
  end

  @spec get_total_by(map()) :: integer()
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

  @spec list_total_by(map()) :: list(integer())
  def list_total_by(filters) do
    RegionPopulation
    |> filter_query(filters)
    |> select([rp], %{total: rp.male + rp.female, year: rp.year})
    |> Repo.all()
    |> Enum.sort(&(&1.year <= &2.year))
    |> Enum.map(& &1.total)
  end

  @spec create(map()) :: {:ok, %RegionPopulation{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %RegionPopulation{}
    |> RegionPopulation.changeset(attrs)
    |> Repo.insert()
  end

  defp filter_query(query, filters) when is_map(filters) do
    filter_query(query, Map.to_list(filters))
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:region_id, region_id} -> where(query, [rp], rp.region_id == ^region_id)
        {:year, year} -> where(query, [rp], rp.year == ^year)
        {:year_period, [from, to]} -> where(query, [rp], rp.year >= ^from and rp.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
