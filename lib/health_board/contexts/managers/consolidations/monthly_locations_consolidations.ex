defmodule HealthBoard.Contexts.Consolidations.MonthlyLocationsConsolidations do
  import Ecto.Query, only: [where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Consolidations.MonthLocationConsolidation
  alias HealthBoard.Repo

  @type schema :: MonthLocationConsolidation.schema()

  @schema MonthLocationConsolidation

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
      {:year, year}, dynamic -> dynamic([row], ^dynamic and row.year == ^year)
      {:years, years}, dynamic -> dynamic([row], ^dynamic and row.year in ^years)
      {:from_year, year}, dynamic -> dynamic([row], ^dynamic and row.year >= ^year)
      {:to_year, year}, dynamic -> dynamic([row], ^dynamic and row.year <= ^year)
      {:month, month}, dynamic -> dynamic([row], ^dynamic and row.month == ^month)
      {:months, months}, dynamic -> dynamic([row], ^dynamic and row.month in ^months)
      {:from_month, month}, dynamic -> dynamic([row], ^dynamic and row.month >= ^month)
      {:to_month, month}, dynamic -> dynamic([row], ^dynamic and row.month <= ^month)
      {:period, period}, dynamic -> filter_by_period(dynamic, period)
      _param, dynamic -> dynamic
    end)
  end

  defp filter_by_period(dynamic, %{from: %{year: y1, month: m1}, to: %{year: y2, month: m2}}) do
    if y1 == y2 do
      if m1 == m2 do
        dynamic([row], ^dynamic and row.year == ^y1 and row.month == ^m1)
      else
        dynamic([row], ^dynamic and row.year == ^y1 and row.month >= ^m1 and row.month <= ^m2)
      end
    else
      if m1 == m2 do
        dynamic([row], ^dynamic and row.year >= ^y1 and row.year <= ^y2 and row.month == ^m1)
      else
        dynamic(
          [row],
          ^dynamic and
            ((row.year == ^y1 and row.month >= ^m1) or (row.year == ^y2 and row.month <= ^m2) or
               (row.year > ^y1 and row.year < ^y2))
        )
      end
    end
  end
end
