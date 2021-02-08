defmodule HealthBoard.Updaters.Helpers do
  require Logger

  @type updater :: %{
          :__struct__ => module,
          :status => atom,
          :statuses => list(atom),
          :error? => boolean,
          :attempts => integer,
          :reattempt_after_milliseconds => integer,
          :reattempt_initial_milliseconds => integer,
          optional(atom) => any
        }

  @spec handle_state(updater) :: updater
  def handle_state(%{__struct__: module} = state) do
    Logger.info("#{module} received request to update. Current status: #{state.status}")

    case state do
      %{status: :new} -> struct(module.new(state), status: List.first(state.statuses))
      %{error?: true} -> struct(state, error?: false)
      state -> state
    end
    |> attempt_to_update()
  rescue
    error ->
      state
      |> handle_error("Unhandled failure from #{module}", error, __STACKTRACE__)
      |> handle_attempt()
  end

  defp attempt_to_update(%{__struct__: module, status: status} = state) do
    case apply(module, status, [state]) do
      %{error?: false} = state -> continue(state)
      state -> handle_attempt(state)
    end
  end

  defp continue(%{__struct__: module, statuses: statuses} = state) do
    case next_status(state.status, statuses) do
      nil ->
        Logger.info("Successfully updated data")

        state
        |> struct(status: :idle)
        |> module.schedule()

      status ->
        state
        |> struct(status: status)
        |> attempt_to_update()
    end
  end

  defp next_status(_status, []), do: nil
  defp next_status(:new, [first_status | _statuses]), do: first_status
  defp next_status(status, [status, next_status | _statuses]), do: next_status
  defp next_status(status, [_other_status | statuses]), do: next_status(status, statuses)

  defp handle_attempt(%{__struct__: module, attempts: attempts} = state) do
    if attempts < 5 do
      attempts = attempts + 1

      milliseconds = state.reattempt_after_milliseconds + state.reattempt_initial_milliseconds * attempts

      state
      |> struct(attempts: attempts, reattempt_after_milliseconds: milliseconds)
      |> schedule(milliseconds)
    else
      Logger.error("#{module} failed 5 times to update data. Reseting state")

      state
      |> module.reset()
      |> module.schedule()
    end
  end

  @spec handle_error(updater, String.t(), any, Exception.stacktrace() | nil) :: updater
  def handle_error(state, message, error, stacktrace \\ nil) do
    Logger.error(fn ->
      error_message =
        if Exception.exception?(error) do
          Exception.message(error)
        else
          inspect(error)
        end

      if is_nil(stacktrace) do
        """
        #{message}. Reason: #{error_message}
        #{inspect(state, pretty: true, limit: :infinity)}
        """
      else
        """
        #{message}. Reason: #{error_message}
        #{inspect(state, pretty: true, limit: :infinity)}
        #{Exception.format_stacktrace(stacktrace)}
        """
      end
    end)

    struct(state, error?: true, last_error: error, last_stacktrace: stacktrace)
  end

  @spec schedule(updater, integer) :: updater
  def schedule(%{__struct__: module, attempts: attempts} = state, milliseconds) do
    Logger.info(fn ->
      if attempts == 0 do
        "#{module} new attempt in #{humanize_milliseconds(milliseconds)}"
      else
        "#{module} attempt ##{attempts + 1} in #{humanize_milliseconds(milliseconds)}"
      end
    end)

    Process.send_after(self(), :update, milliseconds)

    state
  end

  @spec schedule_at_hour(updater, integer) :: updater
  def schedule_at_hour(state, at_hour) do
    schedule(state, milliseconds_to_midnight(at_hour))
  end

  defp milliseconds_to_midnight(offset) do
    :timer.hours(24 + offset) - rem(:os.system_time(:millisecond), :timer.hours(24))
  end

  defp humanize_milliseconds(milliseconds) do
    cond do
      milliseconds < 1_000 -> "#{milliseconds} millisecond(s)"
      milliseconds < 60_000 -> "#{div(milliseconds, 1_000)} second(s)"
      milliseconds < 3_600_000 -> "#{div(milliseconds, 60_000)} minute(s)"
      true -> "#{div(milliseconds, 3_600_000)} hour(s)"
    end
  end
end
