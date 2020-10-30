defmodule HealthBoard.Release.Seeders.Contexts.Logistics do
  alias HealthBoard.Release.Seeders.Contexts.Logistics

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Logistics.HealthInstitution.seed(opts)
  end
end
