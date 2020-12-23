defmodule HealthBoard.Repo.Migrations.SeedSARS do
  use Ecto.Migration

  alias HealthBoard.Release.DataManager

  def up do
    DataManager.PandemicSARSSymptoms.up()
    DataManager.PandemicSARSCases.up()
    DataManager.MonthlySARSCases.up()
    DataManager.WeeklySARSCases.up()
    DataManager.DailySARSCases.up()
  end

  def down do
    DataManager.DailySARSCases.down()
    DataManager.WeeklySARSCases.down()
    DataManager.MonthlySARSCases.down()
    DataManager.PandemicSARSCases.down()
    DataManager.PandemicSARSSymptoms.down()
  end
end
