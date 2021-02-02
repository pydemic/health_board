defmodule HealthBoard.Contexts.Consolidations.WeeklyLocationsConsolidations do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Consolidations.WeeklyLocationConsolidation
  alias HealthBoard.Repo

  @type schema :: WeeklyLocationConsolidation.schema()

  @schema WeeklyLocationConsolidation

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
      {:year, year}, dynamic -> dynamic([row], ^dynamic and row.year == ^year)
      {:from_year, year}, dynamic -> dynamic([row], ^dynamic and row.year >= ^year)
      {:to_year, year}, dynamic -> dynamic([row], ^dynamic and row.year <= ^year)
      {:week, week}, dynamic -> dynamic([row], ^dynamic and row.week == ^week)
      {:from_week, week}, dynamic -> dynamic([row], ^dynamic and row.week >= ^week)
      {:to_week, week}, dynamic -> dynamic([row], ^dynamic and row.week <= ^week)
      _param, dynamic -> dynamic
    end)
  end
end
