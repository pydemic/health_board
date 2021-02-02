defmodule HealthBoard.Repo.Migrations.SeedConsolidations do
  use Ecto.Migration

  alias HealthBoard.Contexts.Seeders

  def down, do: Seeders.Consolidations.down!()
  def up, do: Seeders.Consolidations.up!()
end
