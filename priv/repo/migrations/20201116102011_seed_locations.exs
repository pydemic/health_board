defmodule HealthBoard.Repo.Migrations.SeedLocations do
  use Ecto.Migration

  alias HealthBoard.Release.DataManager

  def up, do: DataManager.Locations.up()
  def down, do: DataManager.Locations.down()
end
