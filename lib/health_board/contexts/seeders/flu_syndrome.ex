defmodule HealthBoard.Contexts.Seeders.FluSyndrome do
  alias HealthBoard.Contexts.Seeders

  @spec down!(keyword) :: :ok
  def down!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)

    if what in [:all, :flu_syndrome, :daily_flu_syndrome_cases], do: Seeders.DailyFluSyndromeCases.down!()
    if what in [:all, :flu_syndrome, :weekly_flu_syndrome_cases], do: Seeders.WeeklyFluSyndromeCases.down!()
    if what in [:all, :flu_syndrome, :monthly_flu_syndrome_cases], do: Seeders.MonthlyFluSyndromeCases.down!()
    if what in [:all, :flu_syndrome, :pandemic_flu_syndrome_cases], do: Seeders.PandemicFluSyndromeCases.down!()

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

    if what in [:all, :flu_syndrome, :pandemic_flu_syndrome_cases], do: Seeders.PandemicFluSyndromeCases.up!(base_path)
    if what in [:all, :flu_syndrome, :monthly_flu_syndrome_cases], do: Seeders.MonthlyFluSyndromeCases.up!(base_path)
    if what in [:all, :flu_syndrome, :weekly_flu_syndrome_cases], do: Seeders.WeeklyFluSyndromeCases.up!(base_path)
    if what in [:all, :flu_syndrome, :daily_flu_syndrome_cases], do: Seeders.DailyFluSyndromeCases.up!(base_path)

    :ok
  end
end
