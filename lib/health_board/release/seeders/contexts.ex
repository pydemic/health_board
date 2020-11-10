defmodule HealthBoard.Release.Seeders.Contexts do
  @app :asis

  alias HealthBoard.Release.Seeders.Contexts

  @spec seed_all(keyword()) :: :ok
  def seed_all(opts \\ []) do
    opts
    |> maybe_load_app()
    |> do_seed_all()
  end

  defp do_seed_all(opts) do
    Contexts.Geo.seed(opts)
    Contexts.Logistics.seed(opts)
    Contexts.Demographic.seed(opts)
    Contexts.Info.seed(opts)
  end

  defp maybe_load_app(opts) do
    if Keyword.get(opts, :load?, false) == true do
      Application.load(@app)
      opts
    else
      opts
    end
  end
end
