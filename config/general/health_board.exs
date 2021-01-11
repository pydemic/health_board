import Config

config :health_board,
  basic_auth_dashboard_password: System.get_env("HEALTH_BOARD__BASIC_AUTH_DASHBOARD_PASSWORD", "Pass@123"),
  basic_auth_system_password: System.get_env("HEALTH_BOARD__BASIC_AUTH_SYSTEM_PASSWORD", "Pass@123"),
  covid_reports_update_at_hour: 3,
  data_path: Path.join(File.cwd!(), ".misc/data"),
  data_updates_path: Path.join(File.cwd!(), ".misc/data_updates"),
  google_api_key: System.get_env("HEALTH_BOARD__GOOGLE_API_KEY"),
  sars_update_at_hour: 3,
  split_command: System.get_env("HEALTH_BOARD__SPLIT_COMMAND", "split"),
  spreadsheet_id: System.get_env("HEALTH_BOARD__SPREADSHEET_ID"),
  spreadsheet_page: System.get_env("HEALTH_BOARD__SPREADSHEET_PAGE"),
  start_updater: String.to_existing_atom(System.get_env("HEALTH_BOARD__START_UPDATER", "false"))
