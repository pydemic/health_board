defmodule HealthBoard.Release.DataManager.Demographic do
  alias HealthBoard.Release.DataManager

  @spec reseed :: :ok
  def reseed do
    DataManager.YearlyPopulations.down()
    DataManager.YearlyPopulations.up()
  end
end
