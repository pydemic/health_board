import Config

config :health_board, HealthBoard.Repo,
  username: "health_board",
  password: "health_board",
  database: "health_board_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("HEALTH_BOARD__POSTGRES_HOSTNAME", "postgres"),
  pool: Ecto.Adapters.SQL.Sandbox
