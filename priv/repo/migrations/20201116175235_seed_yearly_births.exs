defmodule HealthBoard.Repo.Migrations.SeedYearlyBirths do
  use Ecto.Migration

  alias HealthBoard.Release.DataManager

  def up, do: DataManager.YearlyBirths.up()
  def down, do: DataManager.YearlyBirths.down()
end
