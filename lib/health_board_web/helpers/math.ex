defmodule HealthBoardWeb.Helpers.Math do
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
end
