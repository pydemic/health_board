defmodule HealthBoard.Release.DataPuller.DataPullerSupervisor do
  alias HealthBoard.Release.DataPuller.SARSServer
  alias HealthBoard.Release.DataPuller.SeedingServer
  alias HealthBoard.Release.DataPuller.SituationReportServer

  require Logger

  use Supervisor

  def start_link(_arg) do
    Logger.info("Starting the data puller supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      SARSServer,
      SeedingServer,
      SituationReportServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
