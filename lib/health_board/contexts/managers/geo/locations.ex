defmodule HealthBoard.Contexts.Geo.Locations do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Geo.Location
  alias HealthBoard.Repo

  @type schema :: %Location{}

  @schema Location

  @spec get_by(keyword) :: schema | nil
  def get_by(params) do
    @schema
    |> where(^filter_where(params))
    |> Repo.one()
  end

  @spec list_by(keyword) :: list(schema)
  def list_by(params \\ []) do
    @schema
    |> where(^filter_where(params))
    |> order_by(^Keyword.get(params, :order_by, asc: :id))
    |> Repo.all()
  end

  @spec list_siblings_by(integer, keyword) :: list(schema)
  def list_siblings_by(id, params \\ []) do
    case get_by(id: id) do
      nil -> []
      %{parent_id: parent_id} -> list_by(Keyword.put(params, :parent_id, parent_id))
    end
  end

  @spec context!(integer, atom) :: integer
  defdelegate context!(value \\ 0, key), to: HealthBoard.Contexts, as: :location!

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:id, id}, dynamic -> dynamic([row], ^dynamic and row.id == ^id)
      {:ids, ids}, dynamic -> dynamic([row], ^dynamic and row.id in ^ids)
      {:parent_id, id}, dynamic -> dynamic([row], ^dynamic and row.parent_id == ^id)
      {:parents_ids, ids}, dynamic -> dynamic([row], ^dynamic and row.parent_id in ^ids)
      {:context, context}, dynamic -> dynamic([row], ^dynamic and row.context == ^context)
      {:contexts, contexts}, dynamic -> dynamic([row], ^dynamic and row.context in ^contexts)
      _param, dynamic -> dynamic
    end)
  end
end
