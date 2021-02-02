defmodule HealthBoard.Contexts.Geo.Locations do
  import Ecto.Query, only: [from: 2, order_by: 2, where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Geo
  alias HealthBoard.Contexts.Geo.Location
  alias HealthBoard.Repo

  @type schema :: Location.schema()

  @schema Location

  @groups %{
    countries: 0,
    regions: 1,
    states: 2,
    health_regions: 3,
    cities: 4
  }

  @groups_atoms %{
    0 => :countries,
    1 => :regions,
    2 => :states,
    3 => :health_regions,
    4 => :cities
  }

  @spec new(keyword) :: schema
  def new(params \\ []), do: struct(@schema, params)

  # Accessors

  @spec get_by(keyword) :: schema | nil
  def get_by(params) do
    @schema
    |> where(^filter_where(params))
    |> Repo.one!()
  rescue
    error ->
      case Keyword.pop(params, :default) do
        {nil, _params} -> nil
        {:raise, _params} -> reraise(error, __STACKTRACE__)
        {:new, params} -> new(params)
      end
  end

  @spec list_by(keyword) :: list(schema)
  def list_by(params \\ []) do
    @schema
    |> where(^filter_where(params))
    |> order_by(^Keyword.get(params, :order_by, asc: :name))
    |> Repo.all()
  end

  @spec list_children(integer, atom | integer) :: list(schema)
  def list_children(id, group) do
    case get_by(id: id) do
      nil -> []
      schema -> children(schema, group)
    end
  end

  @spec children(schema, atom | integer) :: list(schema)
  def children(schema, group) do
    case preload_children(schema, group) do
      %{children: children} -> Enum.map(children, & &1.child)
      _schema -> []
    end
  end

  @spec list_siblings(integer) :: list(schema)
  def list_siblings(id) do
    case get_by(id: id) do
      nil -> []
      schema -> siblings(schema)
    end
  end

  @spec siblings(schema) :: list(schema)
  def siblings(%{group: group} = schema) do
    case preload_parent(schema, group - 1) do
      %{parents: [%{parent: parent}]} -> children(parent, group)
      _schema -> []
    end
  end

  # Miscellaneous

  @spec group(atom | integer) :: integer
  def group(atom) when is_atom(atom), do: Map.fetch!(@groups, atom)
  def group(integer) when is_integer(integer), do: integer

  @spec group_atom(integer) :: atom
  def group_atom(integer), do: Map.get(@groups_atoms, integer)

  @spec groups(list(atom | integer)) :: list(integer)
  def groups(list), do: Enum.map(list, &group/1)

  @spec region_id(integer, atom) :: integer
  def region_id(id, :states), do: div(id, 10)
  def region_id(id, :health_regions), do: div(id, 10_000)
  def region_id(id, :cities), do: div(id, 1_000_000)

  @spec state_id(integer, atom) :: integer
  def state_id(id, :health_regions), do: div(id, 1_000)
  def state_id(id, :cities), do: div(id, 100_000)

  # Preloads

  @spec preload_children(schema | list(schema), atom | integer) :: schema | list(schema)
  def preload_children(schema_or_schemas, child_group) do
    preloads = [
      children: {
        from(l in Geo.LocationChild, where: l.child_group == ^group(child_group)),
        [child: from(l in Location, order_by: [asc: :name])]
      }
    ]

    Repo.preload(schema_or_schemas, preloads)
  end

  @spec preload_parent(schema | list(schema), atom | integer) :: schema | list(schema)
  def preload_parent(schema_or_schemas, parent_group) do
    preloads = [
      parents: {
        from(l in Geo.LocationChild, where: l.parent_group == ^group(parent_group)),
        [:parent]
      }
    ]

    Repo.preload(schema_or_schemas, preloads)
  end

  # Filtering

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:id, id}, dynamic -> dynamic([row], ^dynamic and row.id == ^id)
      {:ids, ids}, dynamic -> dynamic([row], ^dynamic and row.id in ^ids)
      {:group, group}, dynamic -> dynamic([row], ^dynamic and row.group == ^group(group))
      {:groups, groups}, dynamic -> dynamic([row], ^dynamic and row.group in ^groups(groups))
      _param, dynamic -> dynamic
    end)
  end
end
