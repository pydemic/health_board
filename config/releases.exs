import Config

defmodule HealthBoard.Releases.Env do
  def boolean(name, opts \\ []) do
    with {:ok, value} <- fetch_string(name, opts) do
      String.to_existing_atom(value)
    end
  end

  def integer(name, opts \\ []) do
    with {:ok, value} <- fetch_string(name, opts) do
      String.to_integer(value)
    end
  end

  def list(name, opts \\ []) do
    with {:ok, value} <- fetch_string(name, opts) do
      divider = Keyword.get(opts, :divider, ",")
      values = String.split(value, divider)

      case Keyword.fetch(opts, :formatter) do
        {:ok, formatter} -> Enum.map(values, formatter)
        :error -> values
      end
    end
  end

  def string(name, opts \\ []) do
    with {:ok, value} <- fetch_string(name, opts) do
      value
    end
  end

  defp fetch_string(name, opts) do
    name = parse_prefix(name, opts)

    case {System.get_env(name), Keyword.get(opts, :raise, false), Keyword.fetch(opts, :default)} do
      {nil, true, _default} -> raise "environment variable #{name} is missing"
      {nil, _raise, {:ok, default}} -> default
      {nil, _raise, _default} -> nil
      {value, _raise, _default} -> {:ok, value}
    end
  end

  defp parse_prefix(name, opts) do
    case Keyword.get(opts, :prefix) do
      prefixes when is_list(prefixes) -> Enum.join(["HB" | prefixes] ++ [name], "__")
      prefix when is_binary(prefix) -> "HB__#{prefix}__#{name}"
      _result -> "HB__#{name}"
    end
  end
end

defmodule HealthBoard.Releases.Helper do
  alias HealthBoard.Releases.Env

  def endpoint_settings do
    prefix = "ENDPOINT"

    port = Env.integer("PORT", default: 80, prefix: prefix)

    settings = [
      check_origin: Env.list("ORIGIN_HOSTNAMES", default: [], prefix: prefix),
      http: [
        port: port,
        transport_options: [socket_opts: [:inet6]]
      ],
      secret_key_base: Env.string("SECRET_KEY_BASE", raise: true, prefix: prefix),
      url: [
        host: Env.string("HOSTNAME", raise: true, prefix: prefix),
        port: port
      ]
    ]

    if Env.boolean("HTTPS", default: true, prefix: prefix) do
      prefix = [prefix, "HTTPS"]

      https_settings =
        case Env.string("CACERTFILE_PATH", prefix: prefix) do
          nil -> []
          cacertfile -> [cacertfile: cacertfile]
        end

      Keyword.merge(settings,
        https:
          Keyword.merge(https_settings,
            cipher_suite: :strong,
            certfile: Env.string("CERTFILE_PATH", raise: true, prefix: prefix),
            keyfile: Env.string("KEYFILE_PATH", raise: true, prefix: prefix),
            otp_app: :health_board,
            port: 443
          )
      )
    else
      settings
    end
  end

  def health_board_settings do
    [data_path: Env.string("DATA_PATH", raise: true)]
    |> router_settings()
    |> dashboard_live_settings()
    |> updaters_settings()
  end

  defp router_settings(health_board_settings) do
    prefix = ["ROUTER"]

    []
    |> maybe_append(:dashboard_password, Env.string("DASHBOARD_PASSWORD", prefix: prefix))
    |> maybe_append(:system_password, Env.string("SYSTEM_PASSWORD", prefix: prefix))
    |> maybe_append_to_keyword(:router, health_board_settings)
  end

  defp dashboard_live_settings(health_board_settings) do
    prefix = ["DASHBOARD_LIVE"]

    []
    |> dashboards_data_settings(prefix)
    |> elements_data_settings(prefix)
    |> maybe_append_to_keyword(:dashboard_live, health_board_settings)
  end

  defp dashboards_data_settings(dashboards_live_settings, prefix) do
    prefix = prefix ++ ["DASHBOARDS_DATA"]

    []
    |> maybe_append(:default_dashboard_id, Env.integer("DEFAULT_DASHBOARD_ID", prefix: prefix))
    |> maybe_append(:organizations, Env.list("ORGANIZATIONS", formatter: &parse_organization/1, prefix: prefix))
    |> maybe_append_to_keyword(:dashboards_data, dashboards_live_settings)
  end

  defp parse_organization(organization) do
    case String.split(organization, "___", parts: 2) do
      [url, image] -> {url, image}
      _result -> raise ~s(organization "#{organization}" must follow the pattern: "<url>___<image>")
    end
  end

  defp elements_data_settings(dashboard_live_settings, _prefix) do
    dashboard_live_settings
  end

  defp updaters_settings(health_board_settings) do
    prefix = ["UPDATERS"]

    []
    |> covid_reports_updater_settings(prefix)
    |> icu_occupations_updater_settings(prefix)
    |> flu_syndrome_updater_settings(prefix)
    |> sars_updater_settings(prefix)
    |> case do
      [] -> health_board_settings
      settings -> Keyword.put(health_board_settings, :updaters, children: settings)
    end
  end

  defp covid_reports_updater_settings(updaters_children, prefix) do
    prefix = prefix ++ ["COVID_REPORTS"]

    []
    |> maybe_append(:reattempt_initial_milliseconds, Env.integer("REATTEMPT_INITIAL_MILLISECONDS", prefix: prefix))
    |> maybe_append(:path, Env.string("PATH", prefix: prefix))
    |> maybe_append(:update_at_hour, Env.integer("UPDATE_AT_HOUR", prefix: prefix))
    |> maybe_append(:source_id, Env.integer("SOURCE_ID", prefix: prefix))
    |> maybe_append(:source_sid, Env.string("SOURCE_SID", prefix: prefix))
    |> covid_reports_updater_consolidator_settings(prefix)
    |> covid_reports_updater_header_api_settings(prefix)
    |> case do
      [] -> updaters_children
      settings -> [[module: CovidReportsUpdater, args: settings] | updaters_children]
    end
  end

  defp covid_reports_updater_consolidator_settings(covid_reports_updater_settings, prefix) do
    prefix = prefix ++ ["CONSOLIDATOR"]

    []
    |> maybe_append(:read_ahead, Env.integer("READ_AHEAD", prefix: prefix))
    |> maybe_append(:split_command, Env.string("SPLIT_COMMAND", prefix: prefix))
    |> maybe_append_to_keyword(:consolidator_opts, covid_reports_updater_settings)
  end

  defp covid_reports_updater_header_api_settings(covid_reports_updater_settings, prefix) do
    prefix = prefix ++ ["HEADER_API"]

    []
    |> maybe_append(:read_ahead, Env.string("URL", prefix: prefix))
    |> maybe_append(:split_command, Env.string("APPLICATION_ID", prefix: prefix))
    |> maybe_append_to_keyword(:header_api_opts, covid_reports_updater_settings)
  end

  defp icu_occupations_updater_settings(updaters_children, prefix) do
    prefix = prefix ++ ["ICU_OCCUPATIONS"]

    []
    |> maybe_append(:reattempt_initial_milliseconds, Env.integer("REATTEMPT_INITIAL_MILLISECONDS", prefix: prefix))
    |> maybe_append(:path, Env.string("PATH", prefix: prefix))
    |> maybe_append(:update_at_hour, Env.integer("UPDATE_AT_HOUR", prefix: prefix))
    |> maybe_append(:source_id, Env.integer("SOURCE_ID", prefix: prefix))
    |> maybe_append(:source_sid, Env.string("SOURCE_SID", prefix: prefix))
    |> icu_occupations_updater_spreadsheet_api_settings(prefix)
    |> case do
      [] -> updaters_children
      settings -> [[module: ICUOccupationsUpdater, args: settings] | updaters_children]
    end
  end

  defp icu_occupations_updater_spreadsheet_api_settings(icu_occupations_updater_settings, prefix) do
    prefix = prefix ++ ["SPREADSHEET_API"]

    []
    |> maybe_append(:url, Env.string("URL", prefix: prefix))
    |> maybe_append(:spreadsheet_id, Env.string("SPREADSHEET_ID", prefix: prefix))
    |> maybe_append(:spreadsheet_page, Env.string("SPREADSHEET_PAGE", prefix: prefix))
    |> maybe_append(:token_scope, Env.string("TOKEN_SCOPE", prefix: prefix))
    |> maybe_append_to_keyword(:spreadsheet_api_opts, icu_occupations_updater_settings)
  end

  defp flu_syndrome_updater_settings(updaters_children, prefix) do
    prefix = prefix ++ ["FLU_SYNDROME"]

    []
    |> maybe_append(:reattempt_initial_milliseconds, Env.integer("REATTEMPT_INITIAL_MILLISECONDS", prefix: prefix))
    |> maybe_append(:path, Env.string("PATH", prefix: prefix))
    |> maybe_append(:extractions_path, Env.string("EXTRACTIONS_PATH", prefix: prefix))
    |> maybe_append(:update_at_hour, Env.integer("UPDATE_AT_HOUR", prefix: prefix))
    |> maybe_append(:source_id, Env.integer("SOURCE_ID", prefix: prefix))
    |> maybe_append(:source_sid, Env.string("SOURCE_SID", prefix: prefix))
    |> flu_syndrome_updater_consolidator_settings(prefix)
    |> flu_syndrome_updater_header_api_settings(prefix)
    |> case do
      [] -> updaters_children
      settings -> [[module: FluSyndromeUpdater, args: settings] | updaters_children]
    end
  end

  defp flu_syndrome_updater_consolidator_settings(flu_syndrome_updater_settings, prefix) do
    prefix = prefix ++ ["CONSOLIDATOR"]

    []
    |> maybe_append(:read_ahead, Env.integer("READ_AHEAD", prefix: prefix))
    |> maybe_append(:split_command, Env.string("SPLIT_COMMAND", prefix: prefix))
    |> maybe_append_to_keyword(:consolidator_opts, flu_syndrome_updater_settings)
  end

  defp flu_syndrome_updater_header_api_settings(flu_syndrome_updater_settings, prefix) do
    prefix = prefix ++ ["HEADER_API"]

    []
    |> maybe_append(:read_ahead, Env.string("URL", prefix: prefix))
    |> maybe_append_to_keyword(:header_api_opts, flu_syndrome_updater_settings)
  end

  defp sars_updater_settings(updaters_children, prefix) do
    prefix = prefix ++ ["SARS"]

    []
    |> maybe_append(:reattempt_initial_milliseconds, Env.integer("REATTEMPT_INITIAL_MILLISECONDS", prefix: prefix))
    |> maybe_append(:path, Env.string("PATH", prefix: prefix))
    |> maybe_append(:update_at_hour, Env.integer("UPDATE_AT_HOUR", prefix: prefix))
    |> maybe_append(:source_id, Env.integer("SOURCE_ID", prefix: prefix))
    |> maybe_append(:source_sid, Env.string("SOURCE_SID", prefix: prefix))
    |> sars_updater_consolidator_settings(prefix)
    |> sars_updater_header_api_settings(prefix)
    |> case do
      [] -> updaters_children
      settings -> [[module: SARSUpdater, args: settings] | updaters_children]
    end
  end

  defp sars_updater_consolidator_settings(sars_updater_settings, prefix) do
    prefix = prefix ++ ["CONSOLIDATOR"]

    []
    |> maybe_append(:read_ahead, Env.integer("READ_AHEAD", prefix: prefix))
    |> maybe_append(:split_command, Env.string("SPLIT_COMMAND", prefix: prefix))
    |> maybe_append_to_keyword(:consolidator_opts, sars_updater_settings)
  end

  defp sars_updater_header_api_settings(sars_updater_settings, prefix) do
    prefix = prefix ++ ["HEADER_API"]

    []
    |> maybe_append(:read_ahead, Env.string("URL", prefix: prefix))
    |> maybe_append_to_keyword(:header_api_opts, sars_updater_settings)
  end

  def goth_settings do
    prefix = "GOTH"

    [json: File.read!(Env.string("JSON", prefix: prefix, raise: true))]
  end

  def repo_settings do
    prefix = "DATABASE"

    settings = [
      pool_size: Env.integer("POOL_SIZE", default: 16, prefix: prefix),
      ssl: Env.boolean("SSL", default: false, prefix: prefix),
      timeout: Env.integer("TIMEOUT_MILLISECONDS", default: 600_000, prefix: prefix),
      queue_target: Env.integer("QUEUE_TARGET", default: 10_000, prefix: prefix),
      queue_interval: Env.integer("QUEUE_INTERVAL", default: 100_000, prefix: prefix)
    ]

    case Env.string("URL", prefix: prefix) do
      nil ->
        Keyword.merge(settings,
          database: Env.string("NAME", default: "health_board", prefix: prefix),
          hostname: Env.string("HOSTNAME", default: "postgres", prefix: prefix),
          password: Env.string("PASSWORD", default: "health_board", prefix: prefix),
          username: Env.string("USERNAME", default: "health_board", prefix: prefix)
        )

      url ->
        Keyword.merge(settings, url: url)
    end
  end

  defp maybe_append(keyword, _key, nil), do: keyword
  defp maybe_append(keyword, key, value), do: Keyword.put(keyword, key, value)

  defp maybe_append_to_keyword([], _key, target_keyword), do: target_keyword
  defp maybe_append_to_keyword(keyword, key, target_keyword), do: Keyword.put(target_keyword, key, keyword)
end

alias HealthBoard.Releases.Helper

config :goth, Helper.goth_settings()
config :health_board, HealthBoardWeb.Endpoint, Helper.endpoint_settings()
config :health_board, HealthBoard.Repo, Helper.repo_settings()
config :health_board, Helper.health_board_settings()
