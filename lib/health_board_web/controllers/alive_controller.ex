defmodule HealthBoardWeb.AliveController do
  use HealthBoardWeb, :controller

  @spec list(Plug.Conn.t(), map) :: Plug.Conn.t()
  def list(conn, _params) do
    json(conn, %{alive: true})
  end
end
