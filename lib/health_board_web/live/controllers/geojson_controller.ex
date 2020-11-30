defmodule HealthBoardWeb.GeoJSONController do
  use HealthBoardWeb, :controller

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"path" => path}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_download({:file, geojson_path(path)})
  end

  defp geojson_path(path) do
    :health_board
    |> Application.fetch_env!(:data_path)
    |> Path.join("geojson")
    |> Path.join(path)
  rescue
    _error -> %{}
  end
end
