defmodule HealthBoard.Updaters.SARSUpdater.ConsolidatorManager do
  require Logger

  alias HealthBoard.Updaters.SARSUpdater.Consolidator

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
    |> Keyword.get_lazy(:input_dir, fn -> Path.join(@input_path, "health_board_sars") end)
    |> fetch_files_streams()
    |> Flow.from_enumerable()
    |> Flow.map(&Consolidator.parse/1)
    |> Flow.run()

    Logger.info("Parsing finished")

    opts
    |> Keyword.get_lazy(:output_dir, fn -> Path.join(@output_path, "sars") end)
    |> Consolidator.write()

    if Keyword.get(opts, :shutdown, false) do
      Consolidator.shutdown()
    end
  end

  defp fetch_files_streams(input_dir) do
    [file_name] = File.ls!(input_dir)

    Logger.info("#{file_name} identified")

    today = Date.utc_today()

    input_dir
    |> Path.join(file_name)
    |> File.stream!(read_ahead: 100_000)
    |> NimbleCSV.Semicolon.parse_stream()
    |> Stream.with_index(1)
    |> Stream.map(fn {line, line_index} -> {line_index, today, line} end)
  end
end
