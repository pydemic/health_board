defmodule HealthBoardWeb.DashboardLive.Supervisor do
  alias HealthBoardWeb.DashboardLive.{DashboardsData, ElementsData}
  require Logger

  use Supervisor

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_args) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl Supervisor
  @spec init(any) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(_args) do
    children = [
      DashboardsData,
      ElementsData
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
