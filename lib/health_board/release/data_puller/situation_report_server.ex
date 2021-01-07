defmodule HealthBoard.Release.DataPuller.SituationReportServer do
  alias HealthBoard.Contexts.Info.Source
  alias HealthBoard.Release.DataPuller
  alias HealthBoard.Release.DataPuller.ExternalServices.SituationReport
  alias HealthBoard.Release.DataPuller.SeedingServer
  alias HealthBoard.Repo

  use GenServer

  require Logger

  @name :situation_report_server

  @schema Source
  @source_id "health_board_situation_report"
  # Client Interface

  def start_link(_arg) do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  # Server Callbacks

  def init(init_arg) do
    :inets.start()
    :ssl.start()

    source = Repo.get(@schema, @source_id)
    run_tasks_to_get_situation_report_data(source.last_update_date)
    schedule_refresh()

    {:ok, init_arg}
  end

  def handle_info(:refresh, state) do
    Logger.info("Refreshing the data...")

    source = Repo.get(@schema, @source_id)
    run_tasks_to_get_situation_report_data(source)
    schedule_refresh()

    {:noreply, state}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, calculate_timer_until_next_cycle(-3))
  end

  defp calculate_timer_until_next_cycle(time_zone) do
    :timer.hours(24 - time_zone) - rem(:os.system_time(:millisecond), :timer.hours(24))
  end

  defp run_tasks_to_get_situation_report_data(last_update_date_database) do
    Logger.info("Running tasks to get situation report data...")

    case SituationReport.get_situation_report() do
      {:ok, source_information} ->
        Logger.info("Information about situation report was obtained")

        if is_there_update_from_source?(last_update_date_database, source_information.last_update_date) do
          Logger.info("The database is outdated, it will be updated")

          case download_situation_report_file(source_information) do
            {:ok, :saved_to_file} -> do_consolidate_and_seed(source_information)
            _ -> {:error, :error_download_file}
          end
        else
          Logger.info("The database is updated for situation report data")
          {:ok, :database_is_already_updated}
        end

      _ ->
        {:error, :data_sus_source_information}
    end
  end

  defp is_there_update_from_source?(database_date, source_date) do
    Date.diff(database_date, source_date) < 0
  end

  defp download_situation_report_file(source_information) do
    date = source_information.last_update_date
    url = source_information.url

    year = maybe_put_zero_before_number!(date.year)
    month = maybe_put_zero_before_number!(date.month)
    day = maybe_put_zero_before_number!(date.day)

    path = "/tmp/#{@source_id}/"
    filename = "COVID_REPORT_#{day}-#{month}-#{year}.csv"

    File.rm_rf!(path)
    File.mkdir_p!(path)

    :httpc.request(:get, {String.to_charlist(url), []}, [], stream: String.to_charlist(path <> filename))
  end

  defp maybe_put_zero_before_number!(number) do
    if String.length(Integer.to_string(number)) == 1 do
      "0" <> Integer.to_string(number)
    else
      Integer.to_string(number)
    end
  end

  defp do_consolidate_and_seed(source_information) do
    DataPuller.CovidReports.consolidate()
    SeedingServer.insert_queue(:situation_report, source_information.last_update_date)

    {:ok, :database_will_be_updated}
  end
end
