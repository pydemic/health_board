defmodule HealthBoard.Repo.Migrations.SeedDashboards do
  use Ecto.Migration

  alias HealthBoard.Contexts.Seeders

  def down, do: Seeders.Dashboards.down!()
  def up, do: Seeders.Dashboards.up!()
end
