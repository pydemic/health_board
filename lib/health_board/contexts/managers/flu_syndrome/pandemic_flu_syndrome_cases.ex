defmodule HealthBoard.Contexts.FluSyndrome.PandemicFluSyndromeCases do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]
  alias HealthBoard.Contexts.FluSyndrome.FluSyndromeCases
  alias HealthBoard.Repo

  @type schema :: %FluSyndromeCases{}

  @schema FluSyndromeCases

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

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
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
