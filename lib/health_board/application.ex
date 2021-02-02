defmodule HealthBoard.Application do
  use Application

  @spec start(any(), any()) :: {:ok, pid} | {:error, any()}
  def start(_type, _args) do
    children = [
      # Ecto
      {HealthBoard.Repo, []},
      # Phoenix
      {Phoenix.PubSub, name: HealthBoard.PubSub},
      {HealthBoardWeb.Endpoint, []},
      # Health Board
      {HealthBoardWeb.DashboardLive.Supervisor, Application.fetch_env!(:health_board, :dashboard_live)},
      {HealthBoard.Updaters.Supervisor, Application.fetch_env!(:health_board, :updaters)}
    ]

    opts = [strategy: :one_for_one, name: HealthBoard.Supervisor]

    Supervisor.start_link(children, opts)
  end

  @spec config_change(any(), any(), any()) :: :ok
  def config_change(changed, _new, removed) do
    HealthBoardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
