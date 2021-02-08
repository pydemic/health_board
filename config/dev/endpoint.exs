import Config

config :health_board, HealthBoardWeb.Endpoint,
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  http: [port: 4000],
  https: [
    port: 4001,
    cipher_suite: :strong,
    certfile: Path.expand("../../priv/cert/selfsigned.pem", __DIR__),
    keyfile: Path.expand("../../priv/cert/selfsigned_key.pem", __DIR__)
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/health_board_web/(live|views)/.*(ex)$",
      ~r"lib/health_board_web/templates/.*(eex)$"
    ]
  ],
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch",
      "--watch-options-stdin",
      "--stats",
      "minimal",
      cd: Path.expand("../../assets", __DIR__)
    ]
  ]
