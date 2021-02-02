defmodule HealthBoard.Contexts.Consolidations.ConsolidationsGroups do
  alias HealthBoard.Contexts.Consolidations.ConsolidationGroup
  alias HealthBoard.Repo

  @type schema :: ConsolidationGroup.schema()

  @schema ConsolidationGroup

  @spec fetch!(integer) :: schema
  def fetch!(id), do: Repo.get!(@schema, id)

  @spec fetch_by_name!(String.t() | atom) :: schema
  def fetch_by_name!(name), do: Repo.get_by!(@schema, name: to_string(name))

  @spec fetch_by_name!(String.t() | atom, String.t() | atom, String.t() | atom) :: schema
  def fetch_by_name!(context, group, data), do: fetch_by_name!(name(context, group, data))

  @spec fetch_id!(String.t() | atom) :: integer
  def fetch_id!(name), do: fetch_by_name!(name).id

  @spec fetch_id!(String.t() | atom, String.t() | atom, String.t() | atom) :: integer
  def fetch_id!(context, group, data), do: fetch_id!(name(context, group, data))

  @spec list :: list(schema)
  def list, do: Repo.all(@schema)

  @spec name(String.t() | atom, String.t() | atom, String.t() | atom) :: String.t()
  def name(context, group, data), do: "#{context}_#{group}_#{data}"
end
