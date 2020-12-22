defmodule HealthBoard.Release.DataManager.FluSyndrome do
  alias HealthBoard.Release.DataManager

  @spec reseed :: :ok
  def reseed do
    DataManager.DailyFluSyndromeCases.down()
    DataManager.WeeklyFluSyndromeCases.down()
    DataManager.MonthlyFluSyndromeCases.down()
    DataManager.PandemicFluSyndromeCases.down()

    DataManager.PandemicFluSyndromeCases.up()
    DataManager.MonthlyFluSyndromeCases.up()
    DataManager.WeeklyFluSyndromeCases.up()
    DataManager.DailyFluSyndromeCases.up()
  end
end
