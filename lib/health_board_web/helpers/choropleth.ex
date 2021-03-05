defmodule HealthBoardWeb.Helpers.Choropleth do
  @spec group(list(float | integer), float | integer) :: integer()
  def group(ranges, value) do
    case Enum.find(ranges, &on_boundary?(value, &1)) do
      nil -> 0
      %{group: group} -> group
    end
  end

  @spec group_color(integer) :: String.t()
  def group_color(group_number) do
    case group_number do
      0 -> "#cccccc"
      1 -> "#018571"
      2 -> "#80cdc1"
      3 -> "#ffffbf"
      4 -> "#dfc27d"
      5 -> "#a6611a"
    end
  end

  @spec group_color(list(float | integer), float | integer) :: String.t()
  def group_color(ranges, value) do
    case Enum.find(ranges, &on_boundary?(value, &1)) do
      nil -> "#cccccc"
      %{group: group} -> group_color(group)
    end
  end

  @spec quartile(list(float | integer), keyword) :: list(map)
  def quartile(data, opts \\ []) do
    {q0, q1, q2, q3} = calculate_quartile(data, Keyword.get(opts, :type, :float))

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

  defp calculate_quartile(data, :float) do
    {
      0.0,
      Statistics.percentile(data, 25),
      Statistics.percentile(data, 50),
      Statistics.percentile(data, 75)
    }
  rescue
    _error -> {0.0, 0.0, 0.0, 0.0}
  end

  defp calculate_quartile(data, :integer) do
    {
      0,
      round(Statistics.percentile(data, 25)),
      round(Statistics.percentile(data, 50)),
      round(Statistics.percentile(data, 75))
    }
  rescue
    _error -> {0, 0, 0, 0}
  end

  @spec weighted_distribution(list(float | integer), keyword) :: list(map)
  def weighted_distribution(data, opts \\ []) do
    data
    |> calculate_distribution(Keyword.get(opts, :weights, [50, 75, 85, 95]), Keyword.get(opts, :type, :float))
    |> wrap_ranges()
  end

  defp calculate_distribution(data, weights, type) do
    case type do
      :float -> [0.0 | Enum.map(weights, &Statistics.percentile(data, &1))]
      :integer -> [0 | Enum.map(weights, &round(Statistics.percentile(data, &1)))]
    end
  rescue
    _error ->
      case type do
        :float -> [0.0 | Enum.map(weights, fn _weight -> 0.0 end)]
        :integer -> [0 | Enum.map(weights, fn _weight -> 0 end)]
      end
  end

  defp wrap_ranges(distribution) do
    [nil | distribution]
    |> Enum.zip(distribution ++ [nil])
    |> Enum.with_index()
    |> Enum.map(fn {{from, to}, group} -> %{from: from, to: to, group: group} end)
    |> Enum.reject(&invalid_range?/1)
  end

  defp invalid_range?(%{from: from, to: to}) do
    from == to or (is_nil(from) == false and from > to) or (from == 0.0 and is_nil(to))
  end

  defp on_boundary?(value, boundary) do
    case boundary do
      %{from: nil, to: to} -> value <= to
      %{from: from, to: nil} -> value >= from
      %{from: from, to: to} -> value >= from and value <= to
    end
  end
end
