defmodule HealthBoard.Contexts.Info.Dashboards do
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

  @preloads [
    [
      sections: [
        section: [
          cards: [
            [
              card: [
                indicator: [
                  [children: :child],
                  [sources: :source]
                ]
              ]
            ],
            :filters
          ]
        ]
      ]
    ],
    :disabled_filters
  ]

  @spec preload(schema | list(schema)) :: schema | list(schema)
  def preload(schema_or_schemas), do: Repo.preload(schema_or_schemas, @preloads)
end
