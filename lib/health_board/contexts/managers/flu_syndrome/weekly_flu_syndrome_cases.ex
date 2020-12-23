defmodule HealthBoard.Contexts.FluSyndrome.WeeklyFluSyndromeCases do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]
  alias HealthBoard.Contexts.FluSyndrome.WeekFluSyndromeCases
  alias HealthBoard.Repo

  @type schema :: %WeekFluSyndromeCases{}

  @schema WeekFluSyndromeCases

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
      {:context, context}, dynamic ->
        if is_atom(context) do
          case context do
            :residence -> dynamic([row], ^dynamic and row.context == 0)
            :notification -> dynamic([row], ^dynamic and row.context == 1)
          end
        else
          dynamic([row], ^dynamic and row.context == ^context)
        end

      {:contexts, contexts}, dynamic ->
        dynamic([row], ^dynamic and row.context in ^contexts)

      {:location_id, id}, dynamic ->
        dynamic([row], ^dynamic and row.location_id == ^id)

      {:locations_ids, ids}, dynamic ->
        dynamic([row], ^dynamic and row.location_id in ^ids)

      {:year, year}, dynamic ->
        dynamic([row], ^dynamic and row.year == ^year)

      {:from_year, year}, dynamic ->
        dynamic([row], ^dynamic and row.year >= ^year)

      {:to_year, year}, dynamic ->
        dynamic([row], ^dynamic and row.year <= ^year)

      {:week, week}, dynamic ->
        dynamic([row], ^dynamic and row.week == ^week)

      {:from_week, week}, dynamic ->
        dynamic([row], ^dynamic and row.week >= ^week)

      {:to_week, week}, dynamic ->
        dynamic([row], ^dynamic and row.week <= ^week)

      _param, dynamic ->
        dynamic
    end)
  end
end
