defmodule HealthBoard.Contexts.Demographic.CitiesPopulation do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Demographic.CityPopulation
  alias HealthBoard.Repo

  @spec get_by(map()) :: %CityPopulation{}
  def get_by(filters) do
    CityPopulation
    |> filter_query(filters)
    |> Repo.one()
  end

  @spec get_total_by(map()) :: integer()
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

  @spec list_total_by(map()) :: list(integer())
  def list_total_by(filters) do
    CityPopulation
    |> filter_query(filters)
    |> select([cp], %{total: cp.male + cp.female, year: cp.year})
    |> Repo.all()
    |> Enum.sort(&(&1.year <= &2.year))
    |> Enum.map(& &1.total)
  end

  @spec create(map()) :: {:ok, %CityPopulation{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %CityPopulation{}
    |> CityPopulation.changeset(attrs)
    |> Repo.insert()
  end

  defp filter_query(query, filters) when is_map(filters) do
    filter_query(query, Map.to_list(filters))
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:city_id, city_id} -> where(query, [cp], cp.city_id == ^city_id)
        {:year, year} -> where(query, [cp], cp.year == ^year)
        {:year_period, [from, to]} -> where(query, [cp], cp.year >= ^from and cp.year <= ^to)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
