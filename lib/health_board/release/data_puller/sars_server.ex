# defmodule HealthBoard.Release.DataPuller.SARSServer do
#   alias HealthBoard.Contexts.Info.Source
#   alias HealthBoard.Release.DataPuller
#   alias HealthBoard.Release.DataPuller.ExternalServices.OpenDataSUS
#   alias HealthBoard.Release.DataPuller.SeedingServer
#   alias HealthBoard.Repo

#   use GenServer

#   require Logger

#   @name :sars_server

#   @schema Source
#   @source_id "sivep_srag"

#   # Client Interface

#   @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
#   def start_link(_arg) do
#     GenServer.start(__MODULE__, nil, name: @name)
#   end

#   # Server Callbacks

#   @spec init(any) :: {:ok, any}
#   def init(args) do
#     :inets.start()
#     :ssl.start()

#     schedule_refresh(3_000)

#     {:ok, args}
#   end

#   def handle_info(:refresh, state) do
#     Logger.info("[sars] Running tasks to get data...")

#     case fetch_data() do
#       :ok -> schedule_refresh()
#       _error -> schedule_refresh(60_000)
#     end

#     {:noreply, state}
#   end

#   defp fetch_data do
#     case OpenDataSUS.get_sars_source_information() do
#       {:ok, source_information} ->
#         Logger.info()

#         case maybe_download_data(source_information) do
#           :ok -> consolidate_and_seed(source_information)
#           {:ok, :already_updated} -> :ok
#           error -> error
#         end

#       _ ->
#         {:error, :data_sus_source_information}
#     end
#   end

#   defp maybe_download_data(source_information) do
#     if download_data?(source_information.last_update_date) do
#       Logger.info("[sars] The database is outdated, it will be updated")

#       case download_file(source_information) do
#         {:ok, :saved_to_file} -> :ok
#         _error -> {:error, :failed_to_download}
#       end
#     else
#       Logger.info("[sars] The database is updated")
#       {:ok, :already_updated}
#     end
#   end

#   defp download_data?(database_date, source_date) do
#     Date.diff(database_date, source_date) < 0
#   end

#   defp download_sars_file(source_information) do
#     date = source_information.last_update_date
#     url = source_information.url

#     year = maybe_put_zero_before_number!(date.year)
#     month = maybe_put_zero_before_number!(date.month)
#     day = maybe_put_zero_before_number!(date.day)

#     path = "/tmp/#{@source_id}/"
#     filename = "SIVEP_SRAG_#{day}-#{month}-#{year}.csv"

#     File.rm_rf!(path)
#     File.mkdir_p!(path)

#     :httpc.request(:get, {String.to_charlist(url), []}, [], stream: String.to_charlist(path <> filename))
#   end

#   defp maybe_put_zero_before_number!(number) do
#     if String.length(Integer.to_string(number)) == 1 do
#       "0" <> Integer.to_string(number)
#     else
#       Integer.to_string(number)
#     end
#   end

#   defp do_consolidate_and_seed(source_information) do
#     DataPuller.SARS.consolidate()
#     SeedingServer.insert_queue(:sars, source_information.last_update_date)

#     {:ok, :database_will_be_updated}
#   end

#   defp schedule_refresh(milliseconds \\ nil) do
#     if is_nil(milliseconds) do
#       Process.send_after(self(), :refresh, milliseconds_to_midnight())
#     else
#       Process.send_after(self(), :refresh, milliseconds)
#     end
#   end

#   defp milliseconds_to_midnight() do
#     :timer.hours(27) - rem(:os.system_time(:millisecond), :timer.hours(24))
#   end
# end
