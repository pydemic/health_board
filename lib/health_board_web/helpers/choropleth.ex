defmodule HealthBoardWeb.Helpers.Choropleth do
  @spec group(list(float | integer), float | integer) :: String.t()
  def group(ranges, value) do
    case Enum.find(ranges, &on_boundary?(value, &1)) do
      nil -> 0
      %{group: group} -> group
    end
  end

  @spec quartile(list(float)) :: list(map)
  def quartile(data) do
    {q0, q1, q2, q3} =
      try do
        {
          0.0,
          Statistics.percentile(data, 25),
          Statistics.percentile(data, 50),
          Statistics.percentile(data, 75)
        }
      rescue
        _error -> {0.0, 0.0, 0.0, 0.0}
      end

    [
      %{from: nil, to: q0, group: 0},
      %{from: q0, to: q1, group: 1},
      %{from: q1, to: q2, group: 2},
      %{from: q2, to: q3, group: 3},
      %{from: q3, to: nil, group: 4}
    ]
    |> Enum.reject(
      &(&1.from == &1.to or (is_nil(&1.from) == false and &1.from > &1.to) or (&1.from == 0.0 and &1.to == 0.0) or
          (&1.from == 0.0 and is_nil(&1.to)))
    )
  end

  defp on_boundary?(value, boundary) do
    case boundary do
      %{from: nil, to: to} -> value <= to
      %{from: from, to: nil} -> value >= from
      %{from: from, to: to} -> value >= from and value <= to
    end
  end
end
