defmodule HealthBoard.Release.DataPuller.DataPullerSupervisor do
  # alias HealthBoard.Release.DataPuller.FluSyndromeServer
  alias HealthBoard.Release.DataPuller.SARSServer
  alias HealthBoard.Release.DataPuller.SeedingServer
  alias HealthBoard.Release.DataPuller.SituationReportServer
  use Supervisor

  def start_link(_arg) do
    IO.puts("Starting the data puller supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      # FluSyndromeServer,
      SARSServer,
      SeedingServer,
      SituationReportServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
