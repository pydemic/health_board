defmodule HealthBoard.Release.DataPuller.SarsServer do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Release.DataPuller
  use GenServer

  @name :sars_server

  # Client Interface

  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def get_sars_puller_status do
    GenServer.call(@name, :get_sars_puller_status)
  end

  # Server Callbacks

  def init(_state) do
    :inets.start()
    :ssl.start()

    initial_state = run_tasks_to_get_sars_data()
    schedule_refresh()

    {:ok, initial_state}
  end

  def handle_info(:refresh, _state) do
    IO.puts("Refreshing the data...")
    new_state = run_tasks_to_get_sars_data()
    schedule_refresh()
    {:noreply, new_state}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, calculate_timer_until_next_cycle(-3))
  end

  defp calculate_timer_until_next_cycle(time_zone) do
    :timer.hours(24 - time_zone) - rem(:os.system_time(:millisecond), :timer.hours(24))
  end

  def handle_call(:get_sars_puller_status, _from, state) do
    {:reply, state, state}
  end

  defp run_tasks_to_get_sars_data do
    IO.puts("Running tasks to get sars data...")

    date = ~D[2020-12-28]

    case download_sars_file_from_date(date) do
      {:ok, :saved_to_file} -> do_consolidate_and_seed()
      _ -> IO.puts("Has some problem with URL, stopping downalod and parser")
    end

    {:ok, :sars_populed}
  end

  defp download_sars_file_from_date(date) do
    year = maybe_put_zero_before_number(date.year)
    month = maybe_put_zero_before_number(date.month)
    day = maybe_put_zero_before_number(date.day)

    url = "https://s3-sa-east-1.amazonaws.com/ckan.saude.gov.br/SRAG/#{year}/INFLUD-#{day}-#{month}-#{year}.csv"

    # URL to small box
    # url = "http://dl.dropboxusercontent.com/s/481hq2lssmd2vi6/INFLUD-#{day}-#{month}-#{year}.csv"

    path = "./.misc/source_data/sivep_srag/"
    filename = "SIVEP_SRAG_#{day}-#{month}-#{year}.csv"

    File.rm_rf!(path)
    File.mkdir_p!(path)

    :httpc.request(:get, {String.to_charlist(url), []}, [], stream: String.to_charlist(path <> filename))
  end

  defp maybe_put_zero_before_number(number) do
    if String.length(Integer.to_string(number)) == 1 do
      "0" <> Integer.to_string(number)
    else
      Integer.to_string(number)
    end
  end

  defp do_consolidate_and_seed do
    DataPuller.SARS.consolidate()
    DataManager.SARS.reseed()
  end
end
