defmodule HealthBoard.Application do
  alias HealthBoard.Release.DataPuller.DataPullerSupervisor
  use Application

  @app :health_board

  @spec start(any(), any()) :: {:ok, pid} | {:error, any()}
  def start(_type, _args) do
    children = get_children()

    opts = [strategy: :one_for_one, name: HealthBoard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_children do
    children = [
      HealthBoard.Repo,
      {Phoenix.PubSub, name: HealthBoard.PubSub},
      HealthBoardWeb.Endpoint
    ]

    if Application.fetch_env!(@app, :start_data_puller) do
      [DataPullerSupervisor] ++ children
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
