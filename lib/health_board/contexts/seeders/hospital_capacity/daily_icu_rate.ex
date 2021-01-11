defmodule HealthBoard.Contexts.Seeders.DailyICURate do
  alias HealthBoard.Contexts.Seeder

  @context "hospital_capacity"
  @table_name "daily_icu_rate"
  @columns ~w[location_id date rate]a

  @spec down! :: :ok
  def down!, do: Seeder.down!(@table_name)

  @spec reseed!(String.t() | nil) :: :ok
  def reseed!(base_path \\ nil) do
    up!(base_path)
    down!()
  end

  @spec up!(String.t() | nil) :: :ok
  def up!(base_path \\ nil), do: Seeder.csvs_from_context!(@context, @table_name, @columns, base_path)
end
