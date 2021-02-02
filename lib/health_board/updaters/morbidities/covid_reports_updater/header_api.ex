defmodule HealthBoard.Updaters.CovidReportsUpdater.HeaderAPI do
  use Tesla, only: []

  plug Tesla.Middleware.JSON

  defstruct url: "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral",
            application_id: "unAFkcaNDeXajurGB7LChj8SgQYS2ptm"

  @spec get(keyword) :: {:ok, map} | {:error, atom}
  def get(opts \\ []) do
    case Tesla.get(client(opts), "") do
      {:ok, %{body: data}} -> parse_data(data)
      _error -> {:error, :request_failed}
    end
  end

  defp client(opts) do
    api_data = struct(__MODULE__, opts)

    middleware = [
      {Tesla.Middleware.BaseUrl, api_data.url},
      {Tesla.Middleware.Headers, [{"x-parse-application-id", api_data.application_id}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
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
