defmodule HealthBoard.Updaters.Supervisor do
  use Supervisor
  alias HealthBoard.Updaters

  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    children = Keyword.fetch!(args, :children)

    if Enum.any?(children) do
      Supervisor.start_link(__MODULE__, args, name: __MODULE__)
    else
      :ignore
    end
  end

  @impl Supervisor
  @spec init(keyword) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(args) do
    args
    |> Keyword.fetch!(:children)
    |> Enum.map(&{Module.concat(Updaters, Keyword.fetch!(&1, :module)), Keyword.get(&1, :args, [])})
    |> Supervisor.init(strategy: :one_for_one)
  end
end
