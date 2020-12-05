defmodule HealthBoard.Contexts.Info.DataPeriods do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]

  alias HealthBoard.Contexts.Info.DataPeriod
  alias HealthBoard.Repo

  @type schema :: %DataPeriod{}

  @schema DataPeriod

  @spec new :: schema
  def new, do: %@schema{}

  @spec get_by!(keyword) :: schema
  def get_by!(params) do
    @schema
    |> where(^filter_where(params))
    |> Repo.one!()
    |> @schema.fetch_years
    |> @schema.fetch_weeks
  end

  @spec list_by(keyword) :: list(schema)
  def list_by(params) do
    @schema
    |> where(^filter_where(params))
    |> order_by(^Keyword.get(params, :order_by, asc: :location_id))
    |> Repo.all()
    |> Enum.map(&@schema.fetch_years/1)
  end

  @spec context!(keyword) :: integer
  def context!(keys) do
    HealthBoard.Contexts.fetch!(~w[data_context morbidity mortality registry_location]a, keys)
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:context, context}, dynamic -> dynamic([row], ^dynamic and row.context == ^context)
      {:contexts, contexts}, dynamic -> dynamic([row], ^dynamic and row.context in ^contexts)
      {:location_id, id}, dynamic -> dynamic([row], ^dynamic and row.location_id == ^id)
      {:locations_ids, ids}, dynamic -> dynamic([row], ^dynamic and row.location_id in ^ids)
      _param, dynamic -> dynamic
    end)
  end
end
