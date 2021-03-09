defmodule HealthBoardWeb.GeoController do
  use HealthBoardWeb, :controller
  alias HealthBoardWeb.Helpers.Geo

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"filename" => filename}) do
    case Geo.find_file_path(filename) do
      {:ok, path} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_download({:file, path})

      :error ->
        send_resp(conn, 404, "")
    end
  end
end
