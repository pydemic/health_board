defmodule HealthBoard.Repo.Migrations.SeedFluSyndrome do
  use Ecto.Migration

  alias HealthBoard.Release.DataManager

  def up do
    DataManager.PandemicFluSyndromeCases.up()
    DataManager.MonthlyFluSyndromeCases.up()
    DataManager.WeeklyFluSyndromeCases.up()
    DataManager.DailyFluSyndromeCases.up()
  end

  def down do
    DataManager.DailyFluSyndromeCases.down()
    DataManager.WeeklyFluSyndromeCases.down()
    DataManager.MonthlyFluSyndromeCases.down()
    DataManager.PandemicFluSyndromeCases.down()
  end
end
