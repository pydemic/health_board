defmodule HealthBoard.Contexts.Seeders.SituationReport do
  alias HealthBoard.Contexts.Seeders

  @spec down!(keyword) :: :ok
  def down!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)

    if what in [:all, :covid_reports, :daily_covid_reports], do: Seeders.DailyCOVIDReports.down!()
    if what in [:all, :covid_reports, :weekly_covid_reports], do: Seeders.WeeklyCOVIDReports.down!()
    if what in [:all, :covid_reports, :monthly_covid_reports], do: Seeders.MonthlyCOVIDReports.down!()
    if what in [:all, :covid_reports, :yearly_covid_reports], do: Seeders.YearlyCOVIDReports.down!()
    if what in [:all, :covid_reports, :pandemic_covid_reports], do: Seeders.PandemicCOVIDReports.down!()

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

    if what in [:all, :covid_reports, :pandemic_covid_reports], do: Seeders.PandemicCOVIDReports.up!(base_path)
    if what in [:all, :covid_reports, :yearly_covid_reports], do: Seeders.YearlyCOVIDReports.up!(base_path)
    if what in [:all, :covid_reports, :monthly_covid_reports], do: Seeders.MonthlyCOVIDReports.up!(base_path)
    if what in [:all, :covid_reports, :weekly_covid_reports], do: Seeders.WeeklyCOVIDReports.up!(base_path)
    if what in [:all, :covid_reports, :daily_covid_reports], do: Seeders.DailyCOVIDReports.up!(base_path)

    :ok
  end
end
