defmodule HealthBoardWeb.Helpers.Math do
  @spec death_rate(integer, integer) :: float
  def death_rate(deaths, population) do
    if population > 0 do
      deaths * 100_000 / population
    else
      0.0
    end
  end

  @spec fatality_rate(integer, integer) :: float
  def fatality_rate(deaths, incidence) do
    if incidence > 0 do
      deaths * 100 / incidence
    else
      0.0
    end
  end

  @spec hospitalization_fatality_rate(integer, integer) :: float
  def hospitalization_fatality_rate(deaths, hospitalizations) do
    if hospitalizations > 0 do
      deaths * 100 / hospitalizations
    else
      0.0
    end
  end

  @spec hospitalization_rate(integer, integer) :: float
  def hospitalization_rate(hospitalizations, population) do
    if population > 0 do
      hospitalizations * 10_000 / population
    else
      0.0
    end
  end

  @spec incidence_rate(integer, integer) :: float
  def incidence_rate(incidence, population) do
    if population > 0 do
      incidence * 100_000 / population
    else
      0.0
    end
  end

  @spec moving_average(list(integer | float), integer) :: list(float)
  def moving_average(data, moving_range \\ 7) do
    data
    |> displace_by(moving_range)
    |> Enum.zip()
    |> Enum.map(&calculate_moving_average/1)
  end

  defp displace_by(list, amount, displaced_lists \\ nil) do
    if amount == 0 do
      displaced_lists
    else
      if displaced_lists == nil do
        displace_by(list, amount - 1, [list])
      else
        [list | _displaced_lists] = displaced_lists
        displace_by(list, amount - 1, [[nil | list] | displaced_lists])
      end
    end
  end

  defp calculate_moving_average(displaced_data) do
    displaced_data
    |> Tuple.to_list()
    |> Enum.reverse()
    |> Enum.reject(&is_nil/1)
    |> average()
  end

  defp average(data) do
    if Enum.any?(data) do
      Enum.sum(data) / length(data)
    else
      0.0
    end
  end

  @spec positivity_rate(integer, integer) :: float
  def positivity_rate(confirmed, samples) do
    if samples > 0 do
      confirmed * 100 / samples
    else
      0.0
    end
  end

  @spec test_capacity(integer, integer) :: float
  def test_capacity(confirmed, cases) do
    if cases > 0 do
      confirmed * 100 / cases
    else
      0.0
    end
  end
end
