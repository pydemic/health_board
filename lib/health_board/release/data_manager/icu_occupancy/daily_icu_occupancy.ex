defmodule HealthBoard.Release.DataManager.DailyICUOccupancy do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "icu_occupancy"
  @table_name "daily_icu_occupancy"
  @columns ~w[location_id date rate]a

  @spec up :: :ok
  def up do
    @context
    |> Path.join(@table_name)
    |> DataManager.copy_from_dir!(@table_name, @columns)
  end

  @spec down :: :ok
  def down do
    Repo.query!("TRUNCATE #{@table_name} CASCADE;")
    :ok
  end
end
