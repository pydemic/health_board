defmodule HealthBoard.Repo.Migrations.SeedSARS do
  use Ecto.Migration

  alias HealthBoard.Contexts.Seeders

  def down, do: Seeders.SARS.down!(what: :sars)
  def up, do: Seeders.SARS.up!(what: :sars)
end
