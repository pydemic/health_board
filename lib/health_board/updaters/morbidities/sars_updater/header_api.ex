defmodule HealthBoard.Updaters.SARSUpdater.HeaderAPI do
  defstruct url: "https://opendatasus.saude.gov.br/api/3/action/package_show?id=bd-srag"

  @spec get(keyword) :: {:ok, map} | {:error, atom}
  def get(opts \\ []) do
    with {:ok, d2020} <- do_get(2020, opts),
         {:ok, d2021} <- do_get(2021, opts) do
      {:ok, %{updated_at: d2021.updated_at, urls: [d2020.url, d2021.url]}}
    end
  end

  defp do_get(year, opts) do
    case Tesla.get(client(year, opts), "") do
      {:ok, %{body: data}} -> parse_data(data)
      _error -> {:error, :request_failed}
    end
  end

  defp client(year, opts) do
    api_data = struct(__MODULE__, opts)

    middleware = [
      {Tesla.Middleware.BaseUrl, "#{api_data.url}-#{year}"},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  defp parse_data(data) do
    case data do
      %{"result" => %{"resources" => resources}} -> fetch_csv_resource(resources)
      _data -> {:error, :invalid_data}
    end
  end

  defp fetch_csv_resource(resources) do
    case Enum.find(resources, &(&1["format"] == "CSV")) do
      %{"url" => url} -> parse_url(url)
      _result -> {:error, :resource_not_found}
    end
  end

  defp parse_url(url) do
    url
    |> Path.basename(".csv")
    |> String.split("-")
    |> Enum.drop(1)
    |> Enum.reverse()
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
    |> Date.from_erl()
    |> case do
      {:ok, updated_at} -> {:ok, %{updated_at: updated_at, url: url}}
      _error -> {:error, :invalid_url}
    end
  rescue
    _error -> {:error, :invalid_url}
  end
end
