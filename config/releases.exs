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

  def repo_settings do
    settings = [
      pool_size: get_env("DATABASE_POOL_SIZE", :integer, 16),
      ssl: get_env("DATABASE_SSL", :boolean, false)
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
