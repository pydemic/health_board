defmodule HealthBoard.Repo.Migrations.SeedInfo do
  use Ecto.Migration

  alias HealthBoard.Contexts.Seeders

  def down, do: Seeders.Info.down!(what: :all)
  def up, do: Seeders.Info.up!(what: :all)
end
