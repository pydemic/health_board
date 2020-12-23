defmodule HealthBoard.Release.DataManager.SARS do
  alias HealthBoard.Release.DataManager

  @spec reseed :: :ok
  def reseed do
    DataManager.DailySARSCases.down()
    DataManager.WeeklySARSCases.down()
    DataManager.MonthlySARSCases.down()
    DataManager.PandemicSARSCases.down()
    DataManager.PandemicSARSSymptoms.down()

    DataManager.PandemicSARSSymptoms.up()
    DataManager.PandemicSARSCases.up()
    DataManager.MonthlySARSCases.up()
    DataManager.WeeklySARSCases.up()
    DataManager.DailySARSCases.up()
  end
end
