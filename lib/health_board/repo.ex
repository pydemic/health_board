defmodule HealthBoard.Repo do
  use Ecto.Repo,
    otp_app: :health_board,
    adapter: Ecto.Adapters.Postgres
end
