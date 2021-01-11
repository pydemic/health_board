import Config

config :logger,
  truncate: :infinity

config :logger, :console,
  format: "$time $metadata[$level$levelpad] $message\n",
  metadata: [:mfa, :request_id]
