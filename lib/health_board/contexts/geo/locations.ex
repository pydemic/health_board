defmodule HealthBoard.Contexts.Geo.Locations do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Geo.Location
  alias HealthBoard.Repo

  @type schema :: %Location{}

  @spec get_by(keyword()) :: schema() | nil
  def get_by(params) do
    Location
    |> where(^filter_where(params))
    |> Repo.one()
  end

  @spec list_by(keyword()) :: list(schema())
  def list_by(params \\ []) do
    Location
    |> where(^filter_where(params))
    |> order_by(^Keyword.get(params, :order_by, asc: :id))
    |> Repo.all()
  end

  @spec list_siblings_by(integer(), keyword()) :: list(schema())
  def list_siblings_by(id, params \\ []) do
    case get_by(id: id) do
      nil -> []
      %{parent_id: parent_id} -> list_by(Keyword.put(params, :parent_id, parent_id))
    end
  end

  @spec country_level :: integer()
  def country_level, do: 0

  @spec region_level :: integer()
  def region_level, do: 1

  @spec state_level :: integer()
  def state_level, do: 2

  @spec health_region_level :: integer()
  def health_region_level, do: 3

  @spec city_level :: integer()
  def city_level, do: 4

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:id, id}, dynamic -> dynamic([row], ^dynamic and row.id == ^id)
      {:ids, ids}, dynamic -> dynamic([row], ^dynamic and row.id in ^ids)
      {:parent_id, id}, dynamic -> dynamic([row], ^dynamic and row.parent_id == ^id)
      {:parents_ids, ids}, dynamic -> dynamic([row], ^dynamic and row.parent_id in ^ids)
      {:level, level}, dynamic -> dynamic([row], ^dynamic and row.level == ^level)
      {:levels, levels}, dynamic -> dynamic([row], ^dynamic and row.level in ^levels)
      _param, dynamic -> dynamic
    end)
  end
end
