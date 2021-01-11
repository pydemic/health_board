defmodule HealthBoard.Contexts.Seeders.SARS do
  alias HealthBoard.Contexts.Seeders

  @spec down!(keyword) :: :ok
  def down!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)

    if what in [:all, :sars, :daily_sars_cases], do: Seeders.DailySARSCases.down!()
    if what in [:all, :sars, :weekly_sars_cases], do: Seeders.WeeklySARSCases.down!()
    if what in [:all, :sars, :monthly_sars_cases], do: Seeders.MonthlySARSCases.down!()
    if what in [:all, :sars, :pandemic_sars_cases], do: Seeders.PandemicSARSCases.down!()
    if what in [:all, :sars, :pandemic_sars_symptoms], do: Seeders.PandemicSARSSymptoms.down!()

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

    if what in [:all, :sars, :pandemic_sars_symptoms], do: Seeders.PandemicSARSSymptoms.up!(base_path)
    if what in [:all, :sars, :pandemic_sars_cases], do: Seeders.PandemicSARSCases.up!(base_path)
    if what in [:all, :sars, :monthly_sars_cases], do: Seeders.MonthlySARSCases.up!(base_path)
    if what in [:all, :sars, :weekly_sars_cases], do: Seeders.WeeklySARSCases.up!(base_path)
    if what in [:all, :sars, :daily_sars_cases], do: Seeders.DailySARSCases.up!(base_path)

    :ok
  end
end
