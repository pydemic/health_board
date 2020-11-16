defmodule Mix.Tasks.Seed do
  @moduledoc """
  Mix task to seed contexts.
  """

  use Mix.Task

  alias HealthBoard.Release.Seeders.Contexts

  @spec run(list(String.t())) :: none
  def run(args) do
    Mix.Task.run("app.start")

    if Enum.empty?(args) do
      Contexts.seed()
    else
      seed_each(args)
    end

    exit({:shutdown, 0})
  end

  defp seed_each([context | args]), do: seed_and_continue(context, args)
  defp seed_each(_args), do: :ok

  defp seed_and_continue(context, args) do
    apply(build_module(context), :seed, [])
    seed_each(args)
  end

  defp build_module(context) do
    Module.concat(Contexts, String.to_atom(context))
  end
end
