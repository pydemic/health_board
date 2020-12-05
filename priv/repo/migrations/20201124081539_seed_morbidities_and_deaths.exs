defmodule HealthBoard.Repo.Migrations.SeedMorbiditiesAndDeaths do
  use Ecto.Migration

  alias HealthBoard.Release.DataManager

  def up do
    DataManager.WeeklyDeaths.up()
    DataManager.WeeklyMorbidities.up()
    DataManager.YearlyDeaths.up()
    DataManager.YearlyMorbidities.up()
  end

  def down do
    DataManager.YearlyMorbidities.down()
    DataManager.YearlyDeaths.down()
    DataManager.WeeklyMorbidities.down()
    DataManager.WeeklyDeaths.down()
  end
end
