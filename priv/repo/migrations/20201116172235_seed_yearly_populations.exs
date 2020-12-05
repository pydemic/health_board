defmodule HealthBoard.Repo.Migrations.SeedYearlyPopulations do
  use Ecto.Migration

  alias HealthBoard.Release.DataManager

  def up, do: DataManager.YearlyPopulations.up()
  def down, do: DataManager.YearlyPopulations.down()
end
