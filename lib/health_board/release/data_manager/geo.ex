defmodule HealthBoard.Release.DataManager.Geo do
  alias HealthBoard.Release.DataManager

  @spec reseed :: :ok
  def reseed do
    DataManager.LocationsChildren.down()
    DataManager.Locations.down()

    DataManager.Locations.up()
    DataManager.LocationsChildren.up()
  end
end
