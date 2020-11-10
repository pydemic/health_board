defmodule HealthBoard.Contexts.Geo.HealthRegions do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Geo.HealthRegion
  alias HealthBoard.Repo

  @spec list_ids_by(keyword()) :: list(integer())
  def list_ids_by(filters) do
    HealthRegion
    |> filter_query(filters)
    |> select([hr], hr.id)
    |> Repo.all()
  end

  @spec get!(integer()) :: %HealthRegion{} | nil
  def get!(id) do
    Repo.get!(HealthRegion, id)
  end

  @spec create(map()) :: {:ok, %HealthRegion{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %HealthRegion{}
    |> HealthRegion.changeset(attrs)
    |> Repo.insert()
  end

  defp filter_query(query, filters) when is_map(filters) do
    filter_query(query, Map.to_list(filters))
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:state_id, state_id} -> where(query, [hr], hr.state_id == ^state_id)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
