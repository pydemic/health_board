defmodule HealthBoard.Updaters.ICURateUpdater do
  use GenServer

  require Logger

  alias HealthBoard.Contexts.{Info, Seeders}
  alias HealthBoard.Updaters.{ICURateUpdater, Reseeder}

  @source_id "health_board_hospitalization"

  @type t :: %ICURateUpdater{
          status: atom,
          error?: boolean,
          header: map | nil,
          last_header: map | nil,
          temporary_dir: String.t(),
          update_at_hour: integer,
          attempts: integer,
          last_error: any,
          last_stacktrace: Exception.stacktrace() | nil,
          update_after_milliseconds: integer
        }

  defstruct status: :new,
            error?: false,
            header: nil,
            last_header: nil,
            temporary_dir: "/tmp/health_board/updates",
            update_at_hour: 3,
            attempts: 0,
            last_error: nil,
            last_stacktrace: nil,
            update_after_milliseconds: 60_000

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_args) do
    GenServer.start(ICURateUpdater, nil, [])
  end

  @impl GenServer
  @spec init(any) :: {:ok, t()}
  def init(_args) do
    schedule_update(milliseconds: 3_000)
    {:ok, new_state()}
  end

  @impl GenServer
  @spec handle_info(atom, t()) :: {:noreply, t()}
  def handle_info(:update, %{status: status} = state) do
    Logger.info("Update request received")

    state =
      if state.error? do
        state = struct(state, error?: false, status: :idle)

        case status do
          :extracting_data -> extract_and_continue(state)
          :backing_up_data -> backup_data_and_continue(state)
          :seeding_data -> seed_and_continue(state)
          :updating_source -> update_source_and_continue(state)
          _status -> extract_and_continue(state)
        end
      else
        extract_and_continue(state)
      end

    {:noreply, state}
  end

  defp extract_and_continue(state) do
    attempt_to_update(state, fn state ->
      state
      |> extract_data()
      |> on_valid(:backing_up_data, &backup_data/1)
      |> on_valid(:seeding_data, &seed_data/1)
      |> on_valid(:updating_source, &update_source/1)
    end)
  end

  defp backup_data_and_continue(state) do
    attempt_to_update(state, fn state ->
      state
      |> backup_data()
      |> on_valid(:seeding_data, &seed_data/1)
      |> on_valid(:updating_source, &update_source/1)
    end)
  end

  defp seed_and_continue(state) do
    attempt_to_update(state, fn state ->
      state
      |> seed_data()
      |> on_valid(:updating_source, &update_source/1)
    end)
  end

  defp update_source_and_continue(state) do
    attempt_to_update(state, &update_source/1)
  end

  defp attempt_to_update(state, function) do
    case function.(state) do
      %{error?: false, update_at_hour: update_at_hour, status: status} = state ->
        state =
          if status != :idle do
            Logger.info("Successfully updated data")
            struct(state, status: :idle)
          else
            state
          end

        schedule_update(update_at_hour: update_at_hour)
        state

      %{attempts: attempts, status: status, update_after_milliseconds: update_after_milliseconds} = state ->
        if attempts < 5 do
          update_after_milliseconds = update_after_milliseconds + 60_000 * attempts
          attempts = attempts + 1

          schedule_update(milliseconds: update_after_milliseconds)

          struct(state, attempts: attempts, update_after_milliseconds: update_after_milliseconds)
        else
          Logger.error("Failed 5 times to update data. Not trying again today.")

          if status == :seeding_data do
            rollback_data(state)
          end

          schedule_update(update_at_hour: state.update_at_hour)
          struct(new_state(), status: :idle)
        end
    end
  end

  defp extract_data(%{temporary_dir: dir, last_header: last_header} = state) do
    Logger.info("Extracting data")

    output_dir = Path.join(dir, "output/hospital_capacity")

    case ICURateUpdater.GoogleSpreadsheetAPI.extract(output_dir) do
      {:ok, header} ->
        if update_data?(last_header, header) do
          struct(state, last_header: header, header: header)
        else
          Logger.info("Database is updated")
          struct(state, status: :idle)
        end

      {:error, error} ->
        Logger.error("Failed to extract data. Reason: #{inspect(error)}")
        struct(state, error?: true, last_error: error)
    end
  end

  defp update_data?(last_header, %{updated_at: updated_at}) do
    if is_nil(last_header) do
      case Info.Sources.get(@source_id) do
        {:ok, %{last_update_date: date}} -> Date.compare(updated_at, date) == :gt
        _error -> true
      end
    else
      NaiveDateTime.compare(updated_at, last_header.updated_at) == :gt
    end
  end

  defp backup_data(%{temporary_dir: dir} = state) do
    backup_dir = Path.join(dir, "backup/hospital_capacity")
    output_dir = Path.join(dir, "output/hospital_capacity")

    unless File.dir?(backup_dir) do
      File.mkdir_p!(backup_dir)

      if File.dir?(output_dir) do
        Logger.info("Backing up data from previous update")

        copy_consolidations(output_dir, backup_dir)
      else
        with {:ok, data_path} <- Application.fetch_env(:health_board, :data_path) do
          Logger.info("Backing up data from base data")

          data_path
          |> Path.join("hospital_capacity")
          |> copy_consolidations(backup_dir)
        end
      end
    end

    state
  rescue
    error ->
      Logger.error("Failed to backup data. Reason: #{Exception.message(error)}")
      struct(state, error?: true, last_error: error, last_stacktrace: __STACKTRACE__)
  end

  defp seed_data(%{temporary_dir: dir} = state) do
    case Reseeder.reseed(Seeders.HospitalCapacity, base_path: Path.join(dir, "output"), what: :icu_rate) do
      :ok ->
        dir
        |> Path.join("backup")
        |> remove_consolidations()

        state

      {:error, {error, stacktrace}} ->
        Logger.error("Failed to seed. Reason: #{Exception.message(error)}")
        struct(state, error?: true, last_error: error, last_stacktrace: stacktrace)
    end
  end

  defp update_source(%{header: header} = state) do
    case header do
      %{updated_at: updated_at} ->
        params = %{
          extraction_date: Date.utc_today(),
          last_update_date: updated_at
        }

        case Info.Sources.update(@source_id, params) do
          {:ok, _source} ->
            Logger.info("Updated source")
            state

          {:error, error} ->
            Logger.error("Failed to update source. Reason: #{inspect(error)}")
            struct(state, error?: true, last_error: error)
        end
    end
  end

  defp rollback_data(%{temporary_dir: dir}) do
    backup_dir = Path.join(dir, "backup")

    case Reseeder.reseed(Seeders.SituationReport, base_path: backup_dir, what: :covid_reports) do
      :ok -> Logger.info("Data rolled back")
      _error -> Logger.error("Failed to rollback data")
    end

    remove_consolidations(backup_dir)

    :ok
  end

  defp schedule_update(opts) do
    milliseconds =
      case Keyword.get(opts, :milliseconds) do
        nil -> milliseconds_to_midnight(Keyword.get(opts, :update_at_hour, 0))
        milliseconds -> milliseconds
      end

    Logger.info("New attempt to update in #{humanize_milliseconds(milliseconds)}")

    Process.send_after(self(), :update, milliseconds)
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

  defp new_state do
    %ICURateUpdater{}
    |> maybe_update_update_at_hour()
    |> maybe_update_temporary_dir()
  end

  defp maybe_update_update_at_hour(state) do
    case Application.get_env(:health_board, :covid_reports_update_at_hour) do
      nil -> state
      update_at_hour -> struct(state, update_at_hour: update_at_hour)
    end
  end

  defp maybe_update_temporary_dir(state) do
    case Application.get_env(:health_board, :data_updates_path) do
      nil -> state
      temporary_dir -> struct(state, temporary_dir: temporary_dir)
    end
  end

  defp on_valid(state, status, function) do
    if state.error? or state.status == :idle do
      state
    else
      state
      |> struct(status: status)
      |> function.()
    end
  end

  defp copy_consolidations(source_dir, target_dir) do
    Enum.map(
      ["daily_icu_rate"],
      fn dir ->
        File.cp_r!(
          Path.join(source_dir, dir),
          Path.join(target_dir, dir)
        )
      end
    )
  end

  defp remove_consolidations(dir) do
    Enum.map(
      ["daily_icu_rate"],
      &File.rm_rf!(Path.join(dir, "hospital_capacity/#{&1}"))
    )
  end
end
