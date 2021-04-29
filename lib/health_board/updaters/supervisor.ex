defmodule HealthBoard.Updaters.Supervisor do
  use Supervisor
  alias HealthBoard.Updaters

  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    children = Keyword.get(args, :children, [])

    if Enum.any?(children) do
      Supervisor.start_link(__MODULE__, args, name: __MODULE__)
    else
      :ignore
    end
  end

  @impl Supervisor
  @spec init(keyword) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(args) do
    children = [Updaters.Reseeder | dynamic_children(args)]
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp dynamic_children(args) do
    args
    |> Keyword.fetch!(:children)
    |> Enum.flat_map(&child/1)
  end

  defp child(child_args) do
    args = Keyword.get(child_args, :args, [])

    case Keyword.fetch!(child_args, :module) do
      FluSyndromeUpdater ->
        [{Updaters.FluSyndromeUpdater, args}, {Updaters.FluSyndromeUpdater.Extractor, args}]

      module ->
        {Module.concat(Updaters, module), args}
    end
  end
end
