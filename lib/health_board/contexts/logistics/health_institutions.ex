defmodule HealthBoard.Contexts.Logistics.HealthInstitutions do
  alias HealthBoard.Contexts.Logistics.HealthInstitution
  alias HealthBoard.Repo

  @spec list :: list(%HealthInstitution{})
  def list do
    Repo.all(HealthInstitution)
  end
end
