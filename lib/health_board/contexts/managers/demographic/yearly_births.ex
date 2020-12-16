defmodule HealthBoard.Contexts.Demographic.YearlyBirths do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Demographic.YearBirths
  alias HealthBoard.Repo

  @type schema :: %YearBirths{}

  @schema YearBirths

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

  @spec context!(integer, atom) :: integer
  defdelegate context!(value \\ 0, key), to: HealthBoard.Contexts, as: :registry_location!

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:context, context}, dynamic -> dynamic([row], ^dynamic and row.context == ^context)
      {:location_id, id}, dynamic -> dynamic([row], ^dynamic and row.location_id == ^id)
      {:locations_ids, ids}, dynamic -> dynamic([row], ^dynamic and row.location_id in ^ids)
      {:year, year}, dynamic -> dynamic([row], ^dynamic and row.year == ^year)
      {:from_year, year}, dynamic -> dynamic([row], ^dynamic and row.year >= ^year)
      {:to_year, year}, dynamic -> dynamic([row], ^dynamic and row.year <= ^year)
      _param, dynamic -> dynamic
    end)
  end
end
