defmodule HealthBoard.Contexts.Consolidations.LocationsConsolidations do
  import Ecto.Query, only: [where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Consolidations.LocationConsolidation
  alias HealthBoard.Repo

  @type schema :: LocationConsolidation.schema()

  @schema LocationConsolidation

  @spec new(keyword) :: schema
  def new(params \\ []), do: struct(@schema, params)

  # Accessors

  @spec get_by(keyword) :: schema | nil
  def get_by(params) do
    @schema
    |> where(^filter_where(params))
    |> Repo.one!()
    |> maybe_preload(params[:preload])
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
    |> maybe_preload(params[:preload])
  end

  # Delete

  @spec delete_by(keyword) :: {integer, nil | list(schema)}
  def delete_by(params \\ []) do
    @schema
    |> where(^filter_where(params))
    |> Repo.delete_all()
  end

  # Preload

  defp maybe_preload(schema_or_schemas, preload) do
    case preload do
      :location -> Repo.preload(schema_or_schemas, :location)
      _preload -> schema_or_schemas
    end
  end

  # Filtering

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:consolidation_group_id, id}, dynamic -> dynamic([row], ^dynamic and row.consolidation_group_id == ^id)
      {:location_id, id}, dynamic -> dynamic([row], ^dynamic and row.location_id == ^id)
      {:locations_ids, ids}, dynamic -> dynamic([row], ^dynamic and row.location_id in ^ids)
      _param, dynamic -> dynamic
    end)
  end
end
