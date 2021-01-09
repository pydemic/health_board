defmodule HealthBoard.Release.DataManager.ICUOccupancy do
  alias HealthBoard.Release.DataManager

  @spec down(atom) :: :ok
  def down(what \\ :all) do
    if what in [:all, :icu_occupancies, :daily_icu_occupancies], do: DataManager.DailyICUOccupancy.down()

    :ok
  end

  @spec reseed(atom) :: :ok
  def reseed(what \\ :all) do
    down(what)
    up(what)
  end

  @spec up(atom) :: :ok
  def up(what \\ :all) do
    if what in [:all, :icu_occupancies, :daily_icu_occupancies], do: DataManager.DailyICUOccupancy.up()

    :ok
  end
end
