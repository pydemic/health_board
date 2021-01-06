defmodule HealthBoard.Release.DataPuller.FluSyndromeServer do
  alias HealthBoard.Contexts.Info.Source
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Release.DataPuller
  alias HealthBoard.Release.DataPuller.ExternalServices.OpenDataSUS
  alias HealthBoard.Repo

  use GenServer

  require Logger

  @name :flu_syndrome_server

  @schema Source
  @source_id "e_sus_sg"
  # Client Interface

  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def get_flu_syndrome_puller_status do
    GenServer.call(@name, :get_flu_syndrome_puller_status)
  end

  # Server Callbacks

  def init(_state) do
    :inets.start()
    :ssl.start()

    source = Repo.get(@schema, @source_id)
    initial_state = run_tasks_to_get_flu_syndrome_data(source.last_update_date)
    schedule_refresh()

    {:ok, initial_state}
  end

  def handle_info(:refresh, state) do
    Logger.info("Refreshing the data...")
    {:ok, last_update_date} = state
    new_state = run_tasks_to_get_flu_syndrome_data(last_update_date)
    schedule_refresh()
    {:noreply, new_state}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, calculate_timer_until_next_cycle(-3))
  end

  defp calculate_timer_until_next_cycle(time_zone) do
    :timer.hours(24 - time_zone) - rem(:os.system_time(:millisecond), :timer.hours(24))
  end

  def handle_call(:get_flu_syndrome_puller_status, _from, state) do
    {:reply, state, state}
  end

  defp run_tasks_to_get_flu_syndrome_data(last_update_date_database) do
    Logger.info("Running tasks to get flu syndrome data...")

    case OpenDataSUS.get_flu_syndrome_source_information() do
      {:ok, source_information} ->
        if is_there_update_from_source?(last_update_date_database, source_information.last_update_date) do
          case download_flu_syndrome_files(source_information) do
            {:ok, :saved_to_file} -> do_consolidate_and_seed(source_information)
            _ -> {:error, :error_download_file}
          end
        else
          {:ok, last_update_date_database}
        end

      _ ->
        {:error, :data_sus_source_information}
    end
  end

  defp is_there_update_from_source?(database_date, source_date) do
    Date.diff(database_date, source_date) < 0
  end

  defp download_flu_syndrome_files(source_information) do
    urls = source_information.urls

    path = "/tmp/#{@source_id}/"

    File.rm_rf!(path)
    File.mkdir_p!(path)

    requests_result =
      urls
      |> Enum.map(&download_file(&1, path))
      |> Enum.uniq()

    if length(requests_result) == 1 do
      case Enum.at(requests_result, 0) do
        {:ok, :saved_to_file} -> {:ok, :saved_to_file}
        _ -> {:error, :error_during_file_download}
      end
    else
      {:error, :error_during_file_download}
    end
  end

  defp download_file(url, path) do
    filename = get_filename!(url)
    Logger.info("Downloading file: #{filename}")

    :httpc.request(:get, {String.to_charlist(url), []}, [], stream: String.to_charlist(path <> filename))
  end

  defp get_filename!(url) do
    url
    |> String.split("/")
    |> List.last()
  end

  defp do_consolidate_and_seed(source_information) do
    DataPuller.FluSyndrome.consolidate()
    DataManager.FluSyndrome.reseed()

    source = Repo.get!(@schema, @source_id)

    source =
      Ecto.Changeset.change(source, %{
        last_update_date: source_information.last_update_date,
        extraction_date: Date.utc_today()
      })

    case Repo.update(source) do
      {:ok, _struct} -> {:ok, source_information.last_update_date}
      {:error, _changeset} -> {:error, :error_during_update_date}
    end
  end
end
