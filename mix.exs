defmodule HealthBoard.MixProject do
  use Mix.Project

  def project do
    [
      app: :health_board,
      version: "0.0.1",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      default_release: :health_board,
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: preferred_cli_env(),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      deps: deps(),
      releases: releases()
    ]
  end

  def application do
    [
      mod: {HealthBoard.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      i18n: ["i18n.extract", "i18n.merge.en_US", "i18n.merge.pt_BR"],
      "i18n.extract": ["gettext.extract"],
      "i18n.merge.en_US": ["gettext.merge priv/gettext --locale en_US"],
      "i18n.merge.pt_BR": ["gettext.merge priv/gettext --locale pt_BR"],
      reseed: ["ecto.reset", "seed"],
      setup: ["update.deps", "ecto.setup"],
      start: ["phx.server"],
      test: ["ecto.setup", "test"],
      "test.all": ["test.static", "test.coverage"],
      "test.ci": ["test.static", "ecto.reset", "coveralls.github"],
      "test.coverage": ["ecto.reset", "coveralls"],
      "test.static": ["format --check-formatted", "credo list --all"],
      "update.deps": ["deps.get", "cmd yarn install --cwd assets"]
    ]
  end

  defp deps do
    [
      {:colour_hash, "~> 1.0.3"},
      {:credo, "~> 1.4.1", only: :test, runtime: false},
      {:ecto_psql_extras, "~> 0.4.1"},
      {:ecto_sql, "~> 3.5.2"},
      {:ex_doc, "~> 0.23.0", only: :test, runtime: false},
      {:excoveralls, "~> 0.13.3", only: :test},
      {:floki, "~> 0.29.0", only: :test},
      {:gettext, "~> 0.18.2"},
      {:hackney, "~> 1.16.0"},
      {:jason, "~> 1.2.2"},
      {:nimble_csv, "~> 1.1.0"},
      {:phoenix_ecto, "~> 4.2.1"},
      {:phoenix_html, "~> 2.14.2"},
      {:phoenix_live_dashboard, "~> 0.3.3"},
      {:phoenix_live_reload, "~> 1.2.4", only: :dev},
      {:phoenix_live_view, "~> 0.14.7"},
      {:phoenix, "~> 1.5.6"},
      {:plug_cowboy, "~> 2.4.0"},
      {:postgrex, "~> 0.15.7"},
      {:statistics, "~> 0.6.2"},
      {:telemetry_metrics, "~> 0.6.0"},
      {:telemetry_poller, "~> 0.5.1"},
      {:tesla, "~> 1.3.3"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp preferred_cli_env do
    [
      credo: :test,
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.html": :test,
      "coveralls.post": :test,
      test: :test,
      "test.ci": :test,
      "test.all": :test,
      "test.coverage": :test,
      "test.static": :test
    ]
  end

  defp releases do
    [
      health_board: [
        include_erts: false,
        include_executables_for: [:unix]
      ]
    ]
  end
end
