defmodule HealthBoard.Repo.Migrations.SeedDailyICURate do
  alias HealthBoard.Contexts.Seeders

  use Ecto.Migration

  def down, do: Seeders.HospitalCapacity.down!(what: :daily_icu_rate)
  def up, do: Seeders.HospitalCapacity.up!(what: :daily_icu_rate)
end
