defmodule HealthBoard.Repo.Migrations.SeedLocations do
  use Ecto.Migration

  alias HealthBoard.Release.DataManager

  def up do
    DataManager.Locations.up()
    DataManager.LocationsChildren.up()
  end

  def down do
    DataManager.LocationsChildren.down()
    DataManager.Locations.down()
  end
end
