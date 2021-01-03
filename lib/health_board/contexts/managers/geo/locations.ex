defmodule HealthBoard.Contexts.Geo.Locations do
  import Ecto.Query, only: [from: 2, order_by: 2, where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Geo
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

  @spec list_children(integer, atom | integer) :: list(schema)
  def list_children(id, context) do
    case get_by(id: id) do
      nil -> []
      location -> children(location, context)
    end
  end

  @spec children(schema, atom | integer) :: list(schema)
  def children(schema, context) do
    case preload_children(schema, context) do
      %{children: children} -> Enum.map(children, & &1.child)
      _nil -> []
    end
  end

  @spec list_siblings(integer) :: list(schema)
  def list_siblings(id) do
    case get_by(id: id) do
      nil ->
        []

      %{context: context} = location ->
        case preload_parent(location, context - 1) do
          %{parents: [%{parent: parent}]} -> children(parent, context)
          _parent -> []
        end
    end
  end

  @spec context(atom | integer) :: atom | integer
  defdelegate context(context), to: HealthBoard.Contexts, as: :location

  @spec preload_children(schema | list(schema), atom | integer) :: schema | list(schema)
  def preload_children(struct_or_structs, children_context) do
    children_context = if is_integer(children_context), do: children_context, else: context(children_context)

    preloads = [
      children: {
        from(l in Geo.LocationChild, where: l.child_context == ^children_context),
        [child: from(l in Location, order_by: [asc: :name])]
      }
    ]

    Repo.preload(struct_or_structs, preloads)
  end

  @spec preload_parent(schema | list(schema), atom | integer) :: schema | list(schema)
  def preload_parent(struct_or_structs, parents_context) do
    parents_context = if is_integer(parents_context), do: parents_context, else: context(parents_context)

    preloads = [
      parents: {
        from(l in Geo.LocationChild, where: l.parent_context == ^parents_context),
        [:parent]
      }
    ]

    Repo.preload(struct_or_structs, preloads)
  end

  @spec region_id(integer, atom) :: integer
  def region_id(id, :state), do: div(id, 10)
  def region_id(id, :health_region), do: div(id, 10_000)
  def region_id(id, :city), do: div(id, 1_000_000)

  @spec state_id(integer, atom) :: integer
  def state_id(id, :health_region), do: div(id, 1_000)
  def state_id(id, :city), do: div(id, 100_000)

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:id, id}, dynamic -> dynamic([row], ^dynamic and row.id == ^id)
      {:ids, ids}, dynamic -> dynamic([row], ^dynamic and row.id in ^ids)
      {:context, context}, dynamic -> dynamic([row], ^dynamic and row.context == ^context)
      {:contexts, contexts}, dynamic -> dynamic([row], ^dynamic and row.context in ^contexts)
      _param, dynamic -> dynamic
    end)
  end
end
