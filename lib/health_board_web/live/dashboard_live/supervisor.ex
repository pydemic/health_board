defmodule HealthBoardWeb.DashboardLive.Supervisor do
  alias HealthBoardWeb.DashboardLive.{DashboardsData, ElementsData}
  require Logger

  use Supervisor

  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl Supervisor
  @spec init(keyword) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(args) do
    children = [
      {DashboardsData, Keyword.get(args, :dashboards_data, [])},
      {ElementsData, Keyword.get(args, :elements_data, [])}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
