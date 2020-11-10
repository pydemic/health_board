defmodule HealthBoard.Contexts.Geo.States do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Geo.State
  alias HealthBoard.Repo

  @spec list_ids_by(keyword()) :: list(integer())
  def list_ids_by(filters) do
    City
    |> filter_query(filters)
    |> select([s], s.id)
    |> Repo.all()
  end

  @spec get!(integer()) :: %State{}
  def get!(id) do
    Repo.get!(State, id)
  end

  @spec create(map()) :: {:ok, %State{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %State{}
    |> State.changeset(attrs)
    |> Repo.insert()
  end

  defp filter_query(query, filters) when is_map(filters) do
    filter_query(query, Map.to_list(filters))
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:region_id, region_id} -> where(query, [s], s.region_id == ^region_id)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
