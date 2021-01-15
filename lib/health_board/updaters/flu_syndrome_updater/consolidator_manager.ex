defmodule HealthBoard.Updaters.FluSyndromeUpdater.ConsolidatorManager do
  require Logger

  alias HealthBoard.Updaters.FluSyndromeUpdater.Consolidator

  @input_path "/tmp"
  @output_path Path.join(File.cwd!(), ".misc/data")

  @spec consolidate(keyword) :: :ok
  def consolidate(opts \\ []) do
    if Keyword.get(opts, :init, true) do
      Consolidator.init()
    end

    if Keyword.get(opts, :setup, false) do
      Consolidator.setup()
    end

    opts
    |> Keyword.get_lazy(:input_dir, fn -> Path.join(@input_path, "health_board_flu_syndrome") end)
    |> fetch_files_streams()
    |> Flow.from_enumerables()
    |> Flow.map(&Consolidator.parse/1)
    |> Flow.run()

    Logger.info("Parsing finished")

    opts
    |> Keyword.get_lazy(:output_dir, fn -> Path.join(@output_path, "flu_syndrome") end)
    |> Consolidator.write()

    if Keyword.get(opts, :shutdown, false) do
      Consolidator.shutdown()
    end
  end

  defp fetch_files_streams(input_dir) do
    files_names =
      input_dir
      |> File.ls!()
      |> Enum.sort()
      |> Enum.with_index(1)

    Logger.info("#{Enum.count(files_names)} files identified")

    today = Date.utc_today()

    for {file_name, file_index} <- files_names do
      input_dir
      |> Path.join(file_name)
      |> File.stream!(read_ahead: 100_000)
      |> NimbleCSV.Semicolon.parse_stream()
      |> Stream.with_index(1)
      |> Stream.map(fn {line, line_index} -> {file_index, file_name, line_index, today, line} end)
    end
  end
end
