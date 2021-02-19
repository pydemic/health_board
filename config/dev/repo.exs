import Config

config :health_board, HealthBoard.Repo,
  username: "health_board",
  password: "health_board",
  database: "health_board_dev",
  hostname: "postgres",
  show_sensitive_data_on_connection_error: true,
  pool_size: 8,
  log: false
