defmodule HealthBoard.Application do
  use Application
  alias HealthBoard.Updaters

  @spec start(any(), any()) :: {:ok, pid} | {:error, any()}
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: HealthBoard.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  defp children do
    children = [
      HealthBoard.Repo,
      {Phoenix.PubSub, name: HealthBoard.PubSub},
      HealthBoardWeb.Endpoint
    ]

    if Application.fetch_env!(:health_board, :start_updater) do
      children ++ [Updaters.Supervisor]
    else
      children
    end
  end

  @spec config_change(any(), any(), any()) :: :ok
  def config_change(changed, _new, removed) do
    HealthBoardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
