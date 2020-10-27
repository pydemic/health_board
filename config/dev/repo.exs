import Config

config :health_board, HealthBoard.Repo,
  username: "health_board",
  password: "health_board",
  database: "health_board_dev",
  hostname: System.get_env("HEALTH_BOARD__POSTGRES_HOSTNAME", "postgres"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
