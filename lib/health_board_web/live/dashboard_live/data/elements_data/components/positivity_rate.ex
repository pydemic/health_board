defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.PositivityRate do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components

  @with_discarded_param "with_discarded"

  @samples_scalar_param "samples"
  @positive_scalar_param "positive_#{@samples_scalar_param}"
  @discarded_scalar_param "discarded_#{@samples_scalar_param}"

  @samples_per_location_param "#{@samples_scalar_param}_per_location"
  @positive_samples_per_location_param "#{@positive_scalar_param}_per_location"
  @discarded_samples_per_location_param "#{@discarded_scalar_param}_per_location"

  @spec scalar(map, map) :: {:ok, tuple} | :error
  def scalar(data, params) do
    with {:ok, %{total: t1}} <- Components.fetch_data(data, params, @positive_scalar_param),
         with_discarded? <- Map.has_key?(params, @with_discarded_param),
         key <- if(with_discarded?, do: @discarded_scalar_param, else: @samples_scalar_param),
         {:ok, %{total: t2}} <- Components.fetch_data(data, params, key) do
      Components.scalar(positivity_rate(t1, t2, with_discarded?))
    else
      _result -> :error
    end
  end

  @spec top_ten_locations_table(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def top_ten_locations_table(data, params) do
    with {:ok, [_ | _] = l1} <- Components.fetch_data(data, params, @positive_samples_per_location_param),
         with_discarded? <- Map.has_key?(params, @with_discarded_param),
         key <- if(with_discarded?, do: @discarded_samples_per_location_param, else: @samples_per_location_param),
         {:ok, [_ | _] = l2} <- Components.fetch_data(data, params, key) do
      l1
      |> Components.apply_in_total_per_location(l2, &positivity_rate(&1, &2, with_discarded?))
      |> Components.top_ten_locations_table()
    else
      _result -> :error
    end
  end

  defp positivity_rate(positive_samples, discarded_or_samples, with_discarded?) do
    if is_number(positive_samples) and is_number(discarded_or_samples) and discarded_or_samples > 0 do
      if with_discarded? do
        100 * positive_samples / (positive_samples + discarded_or_samples)
      else
        100 * positive_samples / discarded_or_samples
      end
    else
      0.0
    end
  end
end
