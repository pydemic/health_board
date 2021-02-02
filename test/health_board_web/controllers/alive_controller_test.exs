defmodule HealthBoardWeb.AliveControllerTest do
  use ExUnit.Case, async: true

  use Plug.Test

  test "check if system is alive" do
    response = send_request(conn(:get, "/api/alive"))

    assert response.status == 200
    assert response.resp_body == Jason.encode!(%{alive: true})
  end

  defp send_request(conn) do
    conn
    |> put_private(:plug_skip_csrf_protection, true)
    |> HealthBoardWeb.Endpoint.call([])
  end
end
