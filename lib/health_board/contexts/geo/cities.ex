defmodule HealthBoard.Contexts.Geo.Cities do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Geo.City
  alias HealthBoard.Repo

  @spec list :: list(%City{})
  def list do
    Repo.all(City)
  end

  @spec list_ids_by(keyword()) :: list(integer())
  def list_ids_by(filters) do
    City
    |> filter_query(filters)
    |> select([c], c.id)
    |> Repo.all()
    |> Enum.sort()
  end

  @spec create(map()) :: {:ok, %City{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %City{}
    |> City.changeset(attrs)
    |> Repo.insert()
  end

  defp filter_query(query, filters) when is_map(filters) do
    filter_query(query, Map.to_list(filters))
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:health_region_id, health_region_id} -> where(query, [c], c.health_region_id == ^health_region_id)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
