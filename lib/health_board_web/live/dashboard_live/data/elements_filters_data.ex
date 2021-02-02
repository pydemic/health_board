defmodule HealthBoardWeb.DashboardLive.ElementsFiltersData do
  require Logger

  @spec fetch(map, map, any) :: map
  def fetch(%{options_module: module, options_function: function, options_params: params}, query_params, default) do
    params =
      query_params
      |> Map.merge(URI.decode_query(params || ""))
      |> Map.put("default", default)

    __MODULE__
    |> Module.concat(module)
    |> apply(String.to_atom(function), [params])
  rescue
    error ->
      Logger.error("""
      Failed to fetch filter options: #{Exception.message(error)}
      #{inspect({module, function, params}, pretty: true)}
      #{Exception.format_stacktrace(__STACKTRACE__)}
      """)

      %{name: nil, value: nil, verbose_value: "N/A"}
  end
end
