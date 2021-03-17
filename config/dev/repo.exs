import Config

config :health_board, HealthBoard.Repo,
  username: "health_board",
  password: "health_board",
  database: "health_board_dev",
  hostname: "postgres",
  show_sensitive_data_on_connection_error: true,
  pool_size: 16,
  timeout: 600_000,
  queue_target: 10_000,
  queue_interval: 100_000,
  log: false
