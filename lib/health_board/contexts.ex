defmodule HealthBoard.Contexts do
  @data_contexts %{
    flu_syndrome: 1
  }

  @spec data_context!(integer, atom) :: integer
  def data_context!(value \\ 0, key), do: Map.fetch!(@data_contexts, key) + value

  @spec fetch!(integer, list(atom), keyword) :: integer
  def fetch!(value \\ 0, contexts, keys) do
    contexts
    |> Enum.map(&Keyword.get(keys, &1))
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(value, &fetch_context!(&2, elem(&1, 0), elem(&1, 1)))
  end

  @functions %{
    context: :context!,
    geographic_location: :geographic_location!,
    registry_location: :registry_location!
  }

  defp fetch_context!(value, context, key) do
    apply(__MODULE__, Map.fetch!(@functions, context), [value, key])
  end

  @geographic_locations %{
    country: 0,
    region: 1,
    state: 2,
    health_region: 3,
    city: 4
  }

  @spec location!(integer, atom) :: integer
  def location!(value \\ 0, key), do: Map.fetch!(@geographic_locations, key) + value

  @registry_locations %{
    residence: 0,
    notification: 1,
    cases_residence: 10,
    cases_notification: 11,
    deaths_residence: 20,
    deaths_notification: 21,
    hospitalizations_residence: 30,
    hospitalizations_notification: 31
  }

  @spec registry_location!(integer, atom) :: integer
  def registry_location!(value \\ 0, key), do: Map.fetch!(@registry_locations, key) + value
end
