defmodule HealthBoard.Updaters.SARSUpdater.HeaderAPI do
  use Tesla

  @path "/action/package_show?id=bd-srag-2020"

  plug Tesla.Middleware.BaseUrl, "https://opendatasus.saude.gov.br/api/3"
  plug Tesla.Middleware.JSON

  @spec get :: {:ok, map} | {:error, atom}
  def get do
    case get(@path) do
      {:ok, %{body: data}} -> parse_data(data)
      _error -> {:error, :request_failed}
    end
  end

  defp parse_data(data) do
    with {:ok, resources} <- find_resources(data),
         {:ok, resource} <- find_resource(resources),
         {:ok, url} <- find_url(resource),
         {:ok, updated_at} <- find_updated_at(url) do
      {:ok, %{updated_at: updated_at, url: url}}
    end
  end

  defp find_resources(%{"result" => %{"resources" => resources}}), do: {:ok, resources}
  defp find_resources(_data), do: {:error, :resources_not_found}

  defp find_resource(resources) do
    case Enum.find(resources, &(Map.get(&1, "format") == "CSV")) do
      nil -> {:error, :csv_resource_not_found}
      resource -> {:ok, resource}
    end
  end

  defp find_url(%{"url" => url}), do: {:ok, url}
  defp find_url(_resource), do: {:error, :resource_url_not_found}

  defp find_updated_at(url) do
    url
    |> String.split("/")
    |> List.last()
    |> String.split(".")
    |> List.first()
    |> String.split("-", parts: 2)
    |> List.last()
    |> String.split("-")
    |> Enum.reverse()
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
    |> Date.from_erl()
    |> case do
      {:ok, updated_at} -> {:ok, updated_at}
      _error -> {:error, :updated_at_invalid}
    end
  rescue
    _error -> {:error, :updated_at_not_found}
  end
end
