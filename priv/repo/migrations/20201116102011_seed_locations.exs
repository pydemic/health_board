defmodule HealthBoard.Repo.Migrations.SeedLocations do
  use Ecto.Migration

  alias HealthBoard.Contexts.Seeders

  def down, do: Seeders.Geo.down!(what: :locations)
  def up, do: Seeders.Geo.up!(what: :locations)
end
