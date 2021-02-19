defmodule HealthBoard.Repo do
  require Ecto.Query

  use Ecto.Repo,
    otp_app: :health_board,
    adapter: Ecto.Adapters.Postgres

  @spec order_by(Ecto.Queryable.t(), keyword) :: Ecto.Queryable.t()
  def order_by(query, params) do
    case Keyword.fetch(params, :order_by) do
      {:ok, value} -> Ecto.Query.order_by(query, ^value)
      :error -> query
    end
  end
end
