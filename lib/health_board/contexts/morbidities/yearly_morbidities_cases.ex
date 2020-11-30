defmodule HealthBoard.Contexts.Morbidities.YearlyMorbiditiesCases do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]
  alias HealthBoard.Contexts
  alias HealthBoard.Contexts.Morbidities.YearMorbidityCases
  alias HealthBoard.Repo

  @type schema :: %YearMorbidityCases{}

  @schema YearMorbidityCases

  @spec new :: schema()
  def new, do: %@schema{}

  @spec get_by!(keyword()) :: schema()
  def get_by!(params) do
    @schema
    |> where(^filter_where(params))
    |> Repo.one!()
  end

  @spec list_by(keyword()) :: list(schema())
  def list_by(params) do
    @schema
    |> where(^filter_where(params))
    |> order_by(^Keyword.get(params, :order_by, asc: :location_id))
    |> Repo.all()
  end

  @spec context(atom(), atom()) :: integer()
  def context(morbidity_context, location_context) do
    location_context
    |> Contexts.location_context()
    |> Kernel.+(Contexts.morbidity_context(morbidity_context))
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:context, context}, dynamic -> dynamic([row], ^dynamic and row.context == ^context)
      {:contexts, contexts}, dynamic -> dynamic([row], ^dynamic and row.context in ^contexts)
      {:location_id, id}, dynamic -> dynamic([row], ^dynamic and row.location_id == ^id)
      {:locations_ids, ids}, dynamic -> dynamic([row], ^dynamic and row.location_id in ^ids)
      {:year, year}, dynamic -> dynamic([row], ^dynamic and row.year == ^year)
      {:year_period, [from, to]}, dynamic -> dynamic([row], ^dynamic and row.year >= ^from and row.year <= ^to)
      _param, dynamic -> dynamic
    end)
  end
end
