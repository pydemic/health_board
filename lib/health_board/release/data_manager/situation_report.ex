defmodule HealthBoard.Release.DataManager.SituationReport do
  alias HealthBoard.Release.DataManager

  @spec down(atom) :: :ok
  def down(what \\ :all) do
    if what in [:all, :covid_reports, :daily_covid_reports], do: DataManager.DailyCOVIDReports.down()
    if what in [:all, :covid_reports, :weekly_covid_reports], do: DataManager.WeeklyCOVIDReports.down()
    if what in [:all, :covid_reports, :monthly_covid_reports], do: DataManager.MonthlyCOVIDReports.down()
    if what in [:all, :covid_reports, :yearly_covid_reports], do: DataManager.YearlyCOVIDReports.down()
    if what in [:all, :covid_reports, :pandemic_covid_reports], do: DataManager.PandemicCOVIDReports.down()

    :ok
  end

  @spec reseed(atom) :: :ok
  def reseed(what \\ :all) do
    down(what)
    up(what)
  end

  @spec up(atom) :: :ok
  def up(what \\ :all) do
    if what in [:all, :covid_reports, :pandemic_covid_reports], do: DataManager.PandemicCOVIDReports.up()
    if what in [:all, :covid_reports, :yearly_covid_reports], do: DataManager.YearlyCOVIDReports.up()
    if what in [:all, :covid_reports, :monthly_covid_reports], do: DataManager.MonthlyCOVIDReports.up()
    if what in [:all, :covid_reports, :weekly_covid_reports], do: DataManager.WeeklyCOVIDReports.up()
    if what in [:all, :covid_reports, :daily_covid_reports], do: DataManager.DailyCOVIDReports.up()

    :ok
  end
end
