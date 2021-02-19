defmodule HealthBoard.Contexts.Geo.Locations do
  import Ecto.Query, only: [where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Geo.Location
  alias HealthBoard.Repo

  @type schema :: Location.schema()
  @type group :: atom | integer | String.t()

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
    |> preload_by(params[:preload])
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
    |> Repo.order_by(params)
    |> Repo.all()
    |> preload_by(params[:preload])
  end

  # Relational accessors

  @spec children(schema, group) :: list(schema)
  def children(%{children: children} = schema, child_group) do
    child_group = group(child_group)

    if is_list(children) do
      children
      |> Enum.filter(&(&1.child_group == child_group))
      |> Enum.map(& &1.child)
    else
      children(preload_by(schema, :children), child_group)
    end
  end

  @spec parent(schema, group) :: schema | nil
  def parent(%{parents: parents} = schema, parent_group) do
    parent_group = group(parent_group)

    if is_list(parents) do
      case Enum.find(parents, &(&1.parent_group == parent_group)) do
        %{parent: parent} -> parent
        _result -> nil
      end
    else
      parent(preload_by(schema, :parents), parent_group)
    end
  end

  @spec parent_children(schema, group, group) :: list(schema)
  def parent_children(schema, parent_group, children_group) do
    case parent(schema, parent_group) do
      nil -> []
      parent -> children(parent, children_group)
    end
  end

  @spec related(schema, atom | integer) :: list(schema)
  def related(%{group: group} = schema, related_group) do
    group = group(group)
    related_group = group(related_group)

    cond do
      group == related_group -> parent_children(schema, group - 1, group)
      group < related_group -> children(schema, related_group)
      related_group == 0 -> []
      true -> parent_children(schema, related_group - 1, related_group)
    end
  end

  # Preloads

  @spec preload_by(schema | list(schema), atom) :: schema | list(schema)
  def preload_by(schema_or_schemas, type) do
    case type do
      :parents -> Repo.preload(schema_or_schemas, parents: :parent)
      :children -> Repo.preload(schema_or_schemas, children: :child)
      :all -> Repo.preload(schema_or_schemas, children: :child, parents: :parent)
      _preload -> schema_or_schemas
    end
  end

  # Miscellaneous

  @spec group(atom | integer | String.t()) :: integer
  def group(integer) when is_integer(integer), do: integer
  def group(atom) when is_atom(atom), do: Map.fetch!(@groups, atom)
  def group(string) when is_binary(string), do: group(String.to_atom(string))

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
