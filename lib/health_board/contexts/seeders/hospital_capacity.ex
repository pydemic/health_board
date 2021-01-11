defmodule HealthBoard.Contexts.Seeders.HospitalCapacity do
  alias HealthBoard.Contexts.Seeders

  @spec down!(keyword) :: :ok
  def down!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)

    if what in [:all, :icu_rate, :daily_icu_rate], do: Seeders.DailyICURate.down!()

    :ok
  end

  @spec reseed!(keyword) :: :ok
  def reseed!(opts \\ []) do
    down!(opts)
    up!(opts)
  end

  @spec up!(keyword) :: :ok
  def up!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)
    base_path = Keyword.get(opts, :base_path)

    if what in [:all, :icu_rate, :daily_icu_rate], do: Seeders.DailyICURate.up!(base_path)

    :ok
  end
end
