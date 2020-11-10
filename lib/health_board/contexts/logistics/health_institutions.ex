defmodule HealthBoard.Contexts.Logistics.HealthInstitutions do
  import Ecto.Query, only: [from: 2]
  alias HealthBoard.Contexts.Logistics.HealthInstitution
  alias HealthBoard.Repo

  @spec list :: list(%HealthInstitution{})
  def list do
    Repo.all(HealthInstitution)
  end

  @spec exists?(integer()) :: boolean()
  def exists?(id) do
    Repo.exists?(from hi in HealthInstitution, where: hi.id == ^id)
  end
end
