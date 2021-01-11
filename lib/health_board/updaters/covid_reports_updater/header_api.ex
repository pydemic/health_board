defmodule HealthBoard.Updaters.CovidReportsUpdater.HeaderAPI do
  use Tesla

  @path "/PortalGeral"

  plug Tesla.Middleware.BaseUrl, "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod"
  plug Tesla.Middleware.Headers, [{"x-parse-application-id", "unAFkcaNDeXajurGB7LChj8SgQYS2ptm"}]
  plug Tesla.Middleware.JSON

  @spec get :: {:ok, map} | {:error, atom}
  def get do
    case get(@path) do
      {:ok, %{body: data}} -> parse_data(data)
      _error -> {:error, :request_failed}
    end
  end

  defp parse_data(data) do
    case data do
      %{"results" => [%{"updatedAt" => updated_at, "arquivo" => %{"url" => url}}]} ->
        case NaiveDateTime.from_iso8601(updated_at) do
          {:ok, updated_at} -> {:ok, %{updated_at: updated_at, url: url}}
          _error -> {:error, :invalid_updated_at}
        end

      _data ->
        {:error, :invalid_data}
    end
  end
end
