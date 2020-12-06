defmodule HealthBoard.Release.DataManager.DataPeriods do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "info"
  @table_name "data_periods"
  @columns ~w[data_context context location_id from_date to_date]a

  @spec up :: :ok
  def up do
    DataManager.copy!(@context, @table_name, @columns)
  end

  @spec down :: :ok
  def down do
    Repo.query!("TRUNCATE #{@table_name} CASCADE;")
    :ok
  end
end
