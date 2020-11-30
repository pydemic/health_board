defmodule HealthBoardWeb.DashboardLive.IndicatorsData do
  alias HealthBoard.Contexts.Info.Card
  alias HealthBoardWeb.DashboardLive.IndicatorsData
  alias Phoenix.LiveView

  @type t :: %IndicatorsData{
          card: Card.t() | nil,
          data: map(),
          extra: map(),
          filters: map(),
          group: atom(),
          id: atom(),
          modifiers: map(),
          result: map(),
          socket: LiveView.Socket.t() | nil
        }

  defstruct card: nil,
            data: %{},
            extra: %{},
            filters: %{},
            group: :unknown,
            id: :unknown,
            modifiers: %{},
            result: %{},
            socket: nil

  @spec assign(IndicatorsData.t()) :: LiveView.Socket.t()
  def assign(%{card: card, data: data, group: group, id: id, modifiers: modifiers, result: result, socket: socket}) do
    socket
    |> LiveView.assign(id, %{id: id, card: card, data: data, modifiers: modifiers, result: result})
    |> LiveView.assign_new(group, fn -> true end)
  end

  @spec emit_data(IndicatorsData.t(), atom(), atom()) :: IndicatorsData.t()
  def emit_data(indicators_data, type, sub_type) do
    emit(indicators_data, IndicatorsData.EventData.build(indicators_data, type, sub_type))
  end

  defp emit(%{socket: socket} = indicators_data, {event_name, data}) do
    %IndicatorsData{indicators_data | socket: LiveView.push_event(socket, event_name, data)}
  end

  @spec exec_and_put(IndicatorsData.t(), atom(), function) :: IndicatorsData.t()
  def exec_and_put(indicators_data, key, function) do
    Map.put(indicators_data, key, function.(indicators_data))
  end

  @spec exec_and_put(IndicatorsData.t(), atom(), atom(), function) :: IndicatorsData.t()
  def exec_and_put(indicators_data, key, child_key, function) do
    put(indicators_data, key, child_key, function.(indicators_data))
  end

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(%{id: id} = indicators_data) do
    sub_module =
      "#{id}"
      |> Recase.to_pascal()
      |> String.to_atom()

    IndicatorsData
    |> Module.concat(sub_module)
    |> apply(:fetch, [indicators_data])
  end

  @spec new(LiveView.Socket.t(), atom(), Card.t(), map()) :: IndicatorsData.t()
  def new(socket, id, card, filters) do
    %IndicatorsData{socket: socket, id: id, card: card, filters: filters}
  end

  @spec put(IndicatorsData.t(), atom(), atom(), any()) :: IndicatorsData.t()
  def put(indicators_data, key, child_key, value) do
    case Map.get(indicators_data, key) do
      map when is_map(map) -> Map.put(indicators_data, key, Map.put(map, child_key, value))
    end
  end
end
