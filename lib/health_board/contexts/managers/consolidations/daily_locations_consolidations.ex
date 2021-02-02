defmodule HealthBoard.Contexts.Consolidations.DailyLocationsConsolidations do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Consolidations.DailyLocationConsolidation
  alias HealthBoard.Repo

  @type schema :: DailyLocationConsolidation.schema()

  @schema DailyLocationConsolidation

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

  # Delete

  @spec delete_by(keyword) :: {integer, nil | list(schema)}
  def delete_by(params \\ []) do
    @schema
    |> where(^filter_where(params))
    |> Repo.delete_all()
  end

  # Filtering

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:consolidation_group_id, id}, dynamic -> dynamic([row], ^dynamic and row.consolidation_group_id == ^id)
      {:location_id, id}, dynamic -> dynamic([row], ^dynamic and row.location_id == ^id)
      {:locations_ids, ids}, dynamic -> dynamic([row], ^dynamic and row.location_id in ^ids)
      {:date, date}, dynamic -> dynamic([row], ^dynamic and row.date == ^date)
      {:from_date, date}, dynamic -> dynamic([row], ^dynamic and row.date >= ^date)
      {:to_date, date}, dynamic -> dynamic([row], ^dynamic and row.date <= ^date)
      _param, dynamic -> dynamic
    end)
  end
end
