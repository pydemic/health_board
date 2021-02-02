import Config

config :health_board,
  basic_auth: [dashboard_password: "Pass@123", system_password: "Pass@123"],
  dashboard_live: [],
  seed: [data_path: Path.join(File.cwd!(), ".misc/data")],
  updaters: [children: []]
