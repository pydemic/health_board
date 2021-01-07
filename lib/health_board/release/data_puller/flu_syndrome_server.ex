defmodule HealthBoard.Release.DataPuller.FluSyndromeServer do
  alias HealthBoard.Contexts.Info.Source
  alias HealthBoard.Release.DataPuller
  alias HealthBoard.Release.DataPuller.ExternalServices.OpenDataSUS
  alias HealthBoard.Release.DataPuller.SeedingServer
  alias HealthBoard.Repo

  use GenServer

  require Logger

  @name :flu_syndrome_server

  @schema Source
  @source_id "e_sus_sg"
  # Client Interface

  def start_link(_arg) do
    GenServer.start(__MODULE__, nil, name: @name)
  end

  # Server Callbacks

  def init(init_arg) do
    :inets.start()
    :ssl.start()

    schedule_refresh(init_arg)

    {:ok, init_arg}
  end

  def handle_info(:refresh, state) do
    Logger.info("Refreshing the data...")
    {:ok, last_update_date} = state
    new_state = run_tasks_to_get_flu_syndrome_data(last_update_date)
    schedule_refresh(state)
    {:noreply, new_state}
  end

  defp schedule_refresh(state) do
    if is_nil(state) do
      send(self(), :refresh)
    else
      Process.send_after(self(), :refresh, calculate_timer_until_next_cycle(-3))
    end
  end

  defp calculate_timer_until_next_cycle(time_zone) do
    :timer.hours(24 - time_zone) - rem(:os.system_time(:millisecond), :timer.hours(24))
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
          Logger.info("The database is updated for flu syndrome data")
          {:ok, :database_is_already_updated}
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
    SeedingServer.insert_queue(:situation_report, source_information.last_update_date)

    {:ok, :database_will_be_updated}
  end
end
