defmodule HealthBoard.Repo do
  import Ecto.Query, only: [order_by: 2]

  use Ecto.Repo,
    otp_app: :health_board,
    adapter: Ecto.Adapters.Postgres

  @spec maybe_order_by(Ecto.Queryable.t(), keyword) :: Ecto.Queryable.t()
  def maybe_order_by(query, params) do
    case Keyword.fetch(params, :order_by) do
      {:ok, value} -> order_by(query, ^value)
      :error -> query
    end
  end
end
