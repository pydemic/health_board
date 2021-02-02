defmodule HealthBoard.Contexts.Dashboards.Elements do
  import Ecto.Query, only: [where: 2]

  alias HealthBoard.Contexts.Dashboards.Element
  alias HealthBoard.Repo

  @type schema :: Element.schema()

  @schema Element

  @types %{
    dashboards: 0,
    groups: 1,
    sections: 2,
    cards: 3
  }

  @types_atoms %{
    0 => :dashboards,
    1 => :groups,
    2 => :sections,
    3 => :cards
  }

  # Accessor

  @spec fetch_dashboard(integer) :: {:ok, schema} | {:error, :not_found}
  def fetch_dashboard(id) do
    case get_dashboard(id) do
      nil -> {:error, :not_found}
      dashboard -> {:ok, preload_dashboard(dashboard)}
    end
  end

  defp get_dashboard(id) do
    @schema
    |> where(id: ^id, type: ^type(:dashboards))
    |> Repo.one()
  rescue
    _error -> nil
  end

  defp preload_dashboard(schema_or_schemas) do
    preloads = [
      # dashboards
      :data,
      filters: :filter,
      indicators: :indicator,
      sources: :source,
      children: [
        child: [
          # groups
          :data,
          filters: :filter,
          indicators: :indicator,
          sources: :source,
          children: [
            child: [
              # sections
              :data,
              filters: :filter,
              indicators: :indicator,
              sources: :source,
              children: [
                child: [
                  # cards
                  :data,
                  filters: :filter,
                  indicators: :indicator,
                  sources: :source
                ]
              ]
            ]
          ]
        ]
      ]
    ]

    Repo.preload(schema_or_schemas, preloads)
  end

  # Miscellaneous

  @spec type(atom | integer) :: integer
  def type(atom) when is_atom(atom), do: Map.fetch!(@types, atom)
  def type(integer) when is_integer(integer), do: integer

  @spec type_atom(integer) :: atom
  def type_atom(integer), do: Map.get(@types_atoms, integer)
end
