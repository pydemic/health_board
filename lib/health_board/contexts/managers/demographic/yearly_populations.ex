defmodule HealthBoard.Contexts.Demographic.YearlyPopulations do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Demographic.YearPopulation
  alias HealthBoard.Repo

  @type schema :: %YearPopulation{}

  @schema YearPopulation

  @spec new(keyword) :: schema
  def new(params \\ []) do
    @schema
    |> struct(params)
    |> @schema.add_total()
  end

  @spec get_by(keyword) :: schema
  def get_by(params) do
    @schema
    |> where(^filter_where(params))
    |> Repo.one!()
    |> @schema.add_total()
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
    |> Enum.map(&@schema.add_total/1)
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:location_id, id}, dynamic -> dynamic([row], ^dynamic and row.location_id == ^id)
      {:locations_ids, ids}, dynamic -> dynamic([row], ^dynamic and row.location_id in ^ids)
      {:year, year}, dynamic -> dynamic([row], ^dynamic and row.year == ^year)
      {:from_year, year}, dynamic -> dynamic([row], ^dynamic and row.year >= ^year)
      {:to_year, year}, dynamic -> dynamic([row], ^dynamic and row.year <= ^year)
      _param, dynamic -> dynamic
    end)
  end
end
