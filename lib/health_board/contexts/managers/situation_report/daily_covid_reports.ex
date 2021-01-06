defmodule HealthBoard.Contexts.SituationReport.DailyCOVIDReports do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]
  alias HealthBoard.Contexts.SituationReport.DayCOVIDReports
  alias HealthBoard.Repo

  @type schema :: %DayCOVIDReports{}

  @schema DayCOVIDReports

  @spec new(keyword) :: schema
  def new(params \\ []) do
    struct(@schema, params)
  end

  @spec get_by(keyword) :: schema
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
  def list_by(params) do
    @schema
    |> where(^filter_where(params))
    |> order_by(^Keyword.get(params, :order_by, asc: :location_id))
    |> Repo.all()
  end

  @spec preload(schema | list(schema)) :: schema | list(schema)
  def preload(struct_or_structs) do
    Repo.preload(struct_or_structs, :location)
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:location_id, id}, dynamic -> dynamic([row], ^dynamic and row.location_id == ^id)
      {:locations_ids, ids}, dynamic -> dynamic([row], ^dynamic and row.location_id in ^ids)
      {:date, date}, dynamic -> dynamic([row], ^dynamic and row.date == ^date)
      {:from_date, date}, dynamic -> dynamic([row], ^dynamic and row.date >= ^date)
      {:to_date, date}, dynamic -> dynamic([row], ^dynamic and row.date <= ^date)
      _param, dynamic -> dynamic
    end)
  end
end
