import Config

defmodule HealthBoard.Releases.Helper do
  def endpoint_settings do
    port = get_env("PORT", :integer, 80)

    settings = [
      check_origin: get_env("ORIGIN_HOSTNAMES", :list, []),
      http: [
        port: port,
        transport_options: [socket_opts: [:inet6]]
      ],
      secret_key_base: get_env!("SECRET_KEY_BASE"),
      url: [
        host: get_env!("HOSTNAME"),
        port: port
      ]
    ]

    if get_env("HTTPS", :boolean, true) do
      https_settings =
        case get_env("CACERTFILE_PATH", nil) do
          nil -> []
          cacertfile -> [cacertfile: cacertfile]
        end

      Keyword.merge(settings,
        https:
          Keyword.merge(https_settings,
            cipher_suite: :strong,
            certfile: get_env!("CERTFILE_PATH"),
            keyfile: get_env!("KEYFILE_PATH"),
            otp_app: :health_board,
            port: 443
          )
      )
    else
      settings
    end
  end

  def health_board_settings do
    [
      basic_auth_dashboard_password: get_env!("BASIC_AUTH_DASHBOARD_PASSWORD"),
      basic_auth_system_password: get_env!("BASIC_AUTH_SYSTEM_PASSWORD"),
      covid_reports_update_at_hour: get_env("COVID_REPORTS_UPDATE_AT_HOUR", :integer, 3),
      data_path: get_env!("DATA_PATH"),
      data_updates_path: get_env!("DATA_UPDATES_PATH"),
      google_api_key: get_env!("GOOGLE_API_KEY"),
      sars_update_at_hour: get_env("SARS_UPDATE_AT_HOUR", :integer, 3),
      spreadsheet_id: get_env!("SPREADSHEET_ID"),
      spreadsheet_page: get_env!("SPREADSHEET_PAGE"),
      start_updater: get_env("START_UPDATER", :boolean, true)
    ]
  end

  def repo_settings do
    settings = [
      pool_size: get_env("DATABASE_POOL_SIZE", :integer, 16),
      ssl: get_env("DATABASE_SSL", :boolean, false),
      timeout: 600_000,
      queue_target: 10_000,
      queue_interval: 100_000
    ]

    case get_env("DATABASE_URL", nil) do
      nil ->
        Keyword.merge(settings,
          database: get_env("DATABASE_NAME", "health_board"),
          hostname: get_env("DATABASE_HOSTNAME", "postgres"),
          password: get_env("DATABASE_PASSWORD", "health_board"),
          username: get_env("DATABASE_USERNAME", "health_board")
        )

      url ->
        Keyword.merge(settings, url: url)
    end
  end

  defp get_env(name, type \\ :string, default) do
    env_name = "HEALTH_BOARD__#{name}"

    case {System.get_env(env_name), type} do
      {nil, _type} -> default
      {value, :atom} -> String.to_atom(value)
      {value, :boolean} -> String.to_existing_atom(value)
      {value, :integer} -> String.to_integer(value)
      {value, :list} -> String.split(value, ",")
      {value, :string} -> value
    end
  end

  defp get_env!(env_name, type \\ :string) do
    case get_env(env_name, type, nil) do
      nil -> raise "environment variable #{env_name} is missing"
      value -> value
    end
  end
end

alias HealthBoard.Releases.Helper

config :health_board, HealthBoardWeb.Endpoint, Helper.endpoint_settings()
config :health_board, HealthBoard.Repo, Helper.repo_settings()
config :health_board, Helper.health_board_settings()
