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
    GenServer.start(__MODULE__, nil, name: @name)
  end

  # Server Callbacks

  def init(init_arg) do
    :inets.start()
    :ssl.start()

    schedule_refresh(3_000)

    {:ok, init_arg}
  end

  def handle_info(:refresh, state) do
    Logger.info("[situation_report] Running tasks to get data...")

    case fetch_data() do
      :ok -> schedule_refresh()
      _error -> schedule_refresh(60_000)
    end

    {:noreply, state}
  end

  defp fetch_data() do
    case SituationReport.get_situation_report() do
      {:ok, source_information} ->
        Logger.info("[situation_report] Information was obtained")

        case maybe_download_data(source_information) do
          :ok -> consolidate_and_seed(source_information)
          {:ok, :already_updated} -> :ok
          error -> error
        end

      _error ->
        Logger.error("[situation_report] Failed to get information from API")
        :error
    end
  end

  defp maybe_download_data(source_information) do
    if download_data?(source_information.last_update_date) do
      Logger.info("[situation_report] The database is outdated, it will be updated")

      case download_situation_report_file(source_information) do
        {:ok, :saved_to_file} -> :ok
        _error -> {:error, :failed_to_download}
      end
    else
      Logger.info("[situation_report] The database is updated")
      {:ok, :already_updated}
    end
  end

  defp download_data?(source_date) do
    case Repo.get(@schema, @source_id) do
      nil -> true
      %{last_update_date: date} -> Date.compare(source_date, date) == :gt
    end
  end

  defp download_situation_report_file(source_information) do
    date = source_information.last_update_date
    url = String.to_charlist(source_information.url)

    year = maybe_put_zero_before_number!(date.year)
    month = maybe_put_zero_before_number!(date.month)
    day = maybe_put_zero_before_number!(date.day)

    path = "/tmp/#{@source_id}/"
    filename = "COVID_REPORT_#{day}-#{month}-#{year}.csv"

    File.rm_rf!(path)
    File.mkdir_p!(path)

    :httpc.request(:get, {url, []}, [], stream: String.to_charlist(path <> filename))
  end

  defp maybe_put_zero_before_number!(number) do
    if String.length(Integer.to_string(number)) == 1 do
      "0" <> Integer.to_string(number)
    else
      Integer.to_string(number)
    end
  end

  defp consolidate_and_seed(source_information) do
    DataPuller.CovidReports.consolidate()

    SeedingServer.insert_queue(:situation_report, source_information.last_update_date)

    :ok
  rescue
    error ->
      Logger.error(
        "[situation_report] consolidation failed. Reason: " <>
          Exception.message(error) <> "\n" <> Exception.format_stacktrace(__STACKTRACE__)
      )

      :error
  end

  defp schedule_refresh(milliseconds \\ nil) do
    if is_nil(milliseconds) do
      Process.send_after(self(), :refresh, milliseconds_to_midnight())
    else
      Process.send_after(self(), :refresh, milliseconds)
    end
  end

  defp milliseconds_to_midnight() do
    :timer.hours(27) - rem(:os.system_time(:millisecond), :timer.hours(24))
  end
end
