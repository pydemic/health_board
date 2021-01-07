import Config

config :health_board,
  basic_auth_dashboard_password: System.get_env("HEALTH_BOARD__BASIC_AUTH_DASHBOARD_PASSWORD", "Pass@123"),
  basic_auth_system_password: System.get_env("HEALTH_BOARD__BASIC_AUTH_SYSTEM_PASSWORD", "Pass@123"),
  data_path: Path.join(File.cwd!(), ".misc/data"),
  split_command: System.get_env("HEALTH_BOARD__SPLIT_COMMAND", "split"),
  start_data_puller: false,
  time_zone: -3
