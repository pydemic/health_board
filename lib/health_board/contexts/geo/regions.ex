defmodule HealthBoard.Contexts.Geo.Regions do
  import Ecto.Query, only: [select: 3, where: 3]
  alias HealthBoard.Contexts.Geo.Region
  alias HealthBoard.Repo

  @spec list_ids_by(keyword()) :: list(integer())
  def list_ids_by(filters) do
    City
    |> filter_query(filters)
    |> select([r], r.id)
    |> Repo.all()
  end

  @spec get!(integer()) :: %Region{}
  def get!(id) do
    Repo.get!(Region, id)
  end

  @spec create(map()) :: {:ok, %Region{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %Region{}
    |> Region.changeset(attrs)
    |> Repo.insert()
  end

  defp filter_query(query, filters) when is_map(filters) do
    filter_query(query, Map.to_list(filters))
  end

  defp filter_query(query, filters) do
    if Enum.any?(filters) do
      [filter | filters] = filters

      case filter do
        {:country_id, country_id} -> where(query, [r], r.country_id == ^country_id)
        _unknown -> query
      end
      |> filter_query(filters)
    else
      query
    end
  end
end
