defmodule HealthBoard.Contexts.Info.Dashboards do
  import Ecto.Query, only: [from: 2]

  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.Dashboard
  alias HealthBoard.Repo

  @type schema :: %Dashboard{}

  @schema Dashboard

  @spec list :: list(schema)
  def list do
    Repo.all(@schema)
  end

  @spec get(String.t()) :: {:ok, schema} | {:error, :not_found}
  def get(id) do
    case Repo.get(@schema, id) do
      nil -> {:error, :not_found}
      schema -> {:ok, schema}
    end
  end

  @indicator_preloads [[children: :child], [sources: :source]]
  @card_preloads [indicator: @indicator_preloads]
  @section_card_preloads {from(sc in Info.SectionCard, order_by: sc.index), [[card: @card_preloads], :filters]}
  @section_preloads {from(s in Info.Section, order_by: s.index), [cards: @section_card_preloads]}
  @group_preloads {from(g in Info.Group, order_by: g.index), [sections: @section_preloads]}
  @preloads [groups: @group_preloads]

  @spec preload(schema | list(schema)) :: schema | list(schema)
  def preload(schema_or_schemas), do: Repo.preload(schema_or_schemas, @preloads)
end
