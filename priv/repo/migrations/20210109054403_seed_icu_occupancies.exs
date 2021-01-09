defmodule HealthBoard.Repo.Migrations.SeedICUOccupancies do
  alias HealthBoard.Release.DataManager

  use Ecto.Migration

  def up, do: DataManager.ICUOccupancy.up(:icu_occupancies)
  def down, do: DataManager.ICUOccupancy.down(:icu_occupancies)
end
