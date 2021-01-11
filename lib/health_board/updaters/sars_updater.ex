defmodule HealthBoard.Updaters.SARSUpdater do
  use GenServer

  require Logger

  alias HealthBoard.Contexts.{Info, Seeders}
  alias HealthBoard.Updaters.{Reseeder, SARSUpdater}

  @source_id "sivep_srag"

  @type t :: %SARSUpdater{
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
    GenServer.start(SARSUpdater, nil, [])
  end

  @impl GenServer
  @spec init(any) :: {:ok, t()}
  def init(_args) do
    schedule_update(milliseconds: 3_000)
    {:ok, new_state()}
  end

  @impl GenServer
  @spec handle_info(atom, t()) :: {:noreply, t()}
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def handle_info(:update, %{status: status} = state) do
    Logger.info("Update request received")

    state =
      if state.error? do
        state = struct(state, error?: false, status: :idle)

        case status do
          :fetching_header -> update_and_continue(state)
          :downloading_data -> download_and_continue(state)
          :backing_up_data -> backup_data_and_continue(state)
          :consolidating_data -> consolidate_and_continue(state)
          :seeding_data -> seed_and_continue(state)
          :updating_source -> update_source_and_continue(state)
          _status -> update_and_continue(state)
        end
      else
        if status == :new do
          SARSUpdater.Consolidator.init()
        end

        update_and_continue(state)
      end

    {:noreply, state}
  end

  defp update_and_continue(state) do
    attempt_to_update(state, fn state ->
      state
      |> fetch_header()
      |> on_valid(:downloading_data, &download_data/1)
      |> on_valid(:backing_up_data, &backup_data/1)
      |> on_valid(:consolidating_data, &consolidate_data/1)
      |> on_valid(:seeding_data, &seed_data/1)
      |> on_valid(:updating_source, &update_source/1)
    end)
  end

  defp download_and_continue(state) do
    attempt_to_update(state, fn state ->
      state
      |> download_data()
      |> on_valid(:backing_up_data, &backup_data/1)
      |> on_valid(:consolidating_data, &consolidate_data/1)
      |> on_valid(:seeding_data, &seed_data/1)
      |> on_valid(:updating_source, &update_source/1)
    end)
  end

  defp backup_data_and_continue(state) do
    attempt_to_update(state, fn state ->
      state
      |> backup_data()
      |> on_valid(:consolidating_data, &consolidate_data/1)
      |> on_valid(:seeding_data, &seed_data/1)
      |> on_valid(:updating_source, &update_source/1)
    end)
  end

  defp consolidate_and_continue(state) do
    attempt_to_update(state, fn state ->
      state
      |> consolidate_data()
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

  defp fetch_header(state) do
    Logger.info("Fetching header")

    case SARSUpdater.HeaderAPI.get() do
      {:ok, header} ->
        struct(state, header: header)

      {:error, error} ->
        Logger.error("Failed to fetch header. Reason: #{inspect(error)}")
        struct(state, error?: true, last_error: error)
    end
  end

  defp download_data(%{header: header, last_header: last_header, temporary_dir: dir} = state) do
    if download_data?(last_header, header) do
      Logger.info("Downloading data")

      input_dir = Path.join(dir, "input/sars")

      File.rm_rf!(input_dir)
      File.mkdir_p!(input_dir)

      stream =
        input_dir
        |> Path.join("#{Date.to_iso8601(header.updated_at)}.csv")
        |> String.to_charlist()

      case :httpc.request(:get, {String.to_charlist(header.url), []}, [], stream: stream) do
        {:ok, _result} ->
          struct(state, last_header: header)

        {:error, error} ->
          Logger.error("Failed to download data. Reason: #{inspect(error)}")
          struct(state, error?: true, last_error: error)
      end
    else
      Logger.info("Database is updated")
      struct(state, status: :idle)
    end
  end

  defp download_data?(last_header, %{updated_at: updated_at}) do
    if is_nil(last_header) do
      case Info.Sources.get(@source_id) do
        {:ok, %{last_update_date: date}} -> Date.compare(updated_at, date) == :gt
        _error -> true
      end
    else
      Date.compare(updated_at, last_header.updated_at) == :gt
    end
  end

  defp backup_data(%{temporary_dir: dir} = state) do
    backup_dir = Path.join(dir, "backup/sars")
    output_dir = Path.join(dir, "output/sars")

    unless File.dir?(backup_dir) do
      File.mkdir_p!(backup_dir)

      if File.dir?(output_dir) do
        Logger.info("Backing up data from previous update")

        copy_consolidations(output_dir, backup_dir)
      else
        with {:ok, data_path} <- Application.fetch_env(:health_board, :data_path) do
          Logger.info("Backing up data from base data")

          data_path
          |> Path.join("sars")
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

  defp consolidate_data(%{temporary_dir: dir} = state) do
    output_dir = Path.join(dir, "output/sars")

    remove_consolidations(output_dir)

    SARSUpdater.ConsolidatorManager.consolidate(
      init: false,
      setup: true,
      input_dir: Path.join(dir, "input/sars"),
      output_dir: output_dir
    )

    state
  rescue
    error ->
      Logger.error("Failed to consolidate. Reason: #{Exception.message(error)}")
      struct(state, error?: true, last_error: error, last_stacktrace: __STACKTRACE__)
  end

  defp seed_data(%{temporary_dir: dir} = state) do
    case Reseeder.reseed(Seeders.SARS, base_path: Path.join(dir, "output"), what: :sars) do
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

    case Reseeder.reseed(Seeders.SARS, base_path: backup_dir, what: :sars) do
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
    %SARSUpdater{}
    |> maybe_update_update_at_hour()
    |> maybe_update_temporary_dir()
  end

  defp maybe_update_update_at_hour(state) do
    case Application.get_env(:health_board, :sars_update_at_hour) do
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
      [
        "daily_sars_cases",
        "weekly_sars_cases",
        "monthly_sars_cases",
        "pandemic_sars_cases",
        "pandemic_sars_symptoms"
      ],
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
      [
        "daily_sars_cases",
        "weekly_sars_cases",
        "monthly_sars_cases",
        "pandemic_sars_cases",
        "pandemic_sars_symptoms"
      ],
      &File.rm_rf!(Path.join(dir, "sars/#{&1}"))
    )
  end
end
