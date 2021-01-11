defmodule HealthBoard.Repo.Migrations.SeedFluSyndrome do
  use Ecto.Migration

  alias HealthBoard.Contexts.Seeders

  def down, do: Seeders.FluSyndrome.down!(what: :flu_syndrome)
  def up, do: Seeders.FluSyndrome.up!(what: :flu_syndrome)
end
