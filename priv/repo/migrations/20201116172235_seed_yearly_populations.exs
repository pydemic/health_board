defmodule HealthBoard.Repo.Migrations.SeedYearlyPopulations do
  use Ecto.Migration

  alias HealthBoard.Contexts.Seeders

  def down, do: Seeders.Demographic.down!(what: :yearly_populations)
  def up, do: Seeders.Demographic.up!(what: :yearly_populations)
end
