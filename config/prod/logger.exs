import Config

config :logger, level: :info

config :logger, :console,
  format: "$date $time $metadata[$level$levelpad] $message\n",
  metadata: [:mfa]
