defmodule HealthBoard.Contexts.Info.DataPeriods do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]
  alias HealthBoard.Contexts.Info.DataPeriod
  alias HealthBoard.Repo

  @type schema :: %DataPeriod{}

  @schema DataPeriod

  @spec new :: schema()
  def new, do: %@schema{}

  @spec get_by!(keyword()) :: schema()
  def get_by!(params) do
    @schema
    |> where(^filter_where(params))
    |> Repo.one!()
    |> @schema.fetch_years()
  end

  @spec list_by(keyword()) :: list(schema())
  def list_by(params) do
    @schema
    |> where(^filter_where(params))
    |> order_by(^Keyword.get(params, :order_by, asc: :location_id))
    |> Repo.all()
    |> Enum.map(&@schema.fetch_years/1)
  end

  @spec morbidity_context(atom(), integer()) :: integer()
  def morbidity_context(morbidity, location_context) do
    value = 10_000 + location_context

    case morbidity do
      :botulism -> value
      :chikungunya -> value + 100
      :cholera -> value + 200
      :hantavirus -> value + 300
      :human_rabies -> value + 400
      :malaria_from_extra_amazon -> value + 500
      :plague -> value + 600
      :spotted_fever -> value + 700
      :yellow_fever -> value + 800
      :zika -> value + 900
    end
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
