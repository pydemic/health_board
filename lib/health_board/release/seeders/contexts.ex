defmodule HealthBoard.Release.Seeders.Contexts do
  @app :asis

  alias HealthBoard.Release.Seeders.Contexts

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    opts
    |> maybe_load_app()
    |> seed_all()
  end

  defp seed_all(opts) do
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
