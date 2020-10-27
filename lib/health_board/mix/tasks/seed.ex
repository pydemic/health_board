defmodule Mix.Tasks.Seed do
  @moduledoc """
  Mix task to seed contexts.
  """

  use Mix.Task

  alias HealthBoard.Release.Seeders.Contexts
  alias HealthBoard.Release.Seeders.Contexts.Geo

  @spec run(list(String.t())) :: none
  def run(args) do
    case args do
      ["sync" | args] -> do_run(args, sync: true)
      args -> do_run(args)
    end

    exit({:shutdown, 0})
  end

  defp do_run(args, opts \\ []) do
    Mix.Task.run("app.start")

    if Enum.empty?(args) do
      Contexts.seed_all(opts)
    else
      seed_each(args, opts)
    end
  end

  defp seed_each([context | args], opts), do: seed_and_continue(context, args, opts)
  defp seed_each(_args, _opts), do: :ok

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp seed_and_continue(context, args, opts) do
    case context do
      "geo" -> Geo.seed(opts)
      "geo.country" -> Geo.Country.seed(opts)
      "geo.region" -> Geo.Region.seed(opts)
      "geo.state" -> Geo.State.seed(opts)
      "geo.health_region" -> Geo.HealthRegion.seed(opts)
      "geo.city" -> Geo.City.seed(opts)
      _ -> :ok
    end

    seed_each(args, opts)
  end
end
