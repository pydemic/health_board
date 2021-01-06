defmodule HealthBoard.Release.DataPuller.CovidReports do
  require Logger

  alias HealthBoard.Release.DataPuller.CovidReports.Consolidator

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @spec consolidate(keyword) :: :ok
  def consolidate(opts \\ []) do
    if Keyword.get(opts, :init, true) do
      Consolidator.init()
    end

    if Keyword.get(opts, :setup, false) do
      Consolidator.setup()
    end

    after_date = Keyword.get(opts, :after_date)

    opts
    |> Keyword.get_lazy(:input_dir, fn -> Path.join(@dir, "input") end)
    |> fetch_file_stream()
    |> Flow.from_enumerable()
    |> Flow.map(&Consolidator.parse(&1, after_date))
    |> Flow.run()

    Logger.info("Parsing finished")

    case Keyword.get(opts, :type, :file) do
      :file -> Consolidator.write(Keyword.get_lazy(opts, :output_dir, fn -> Path.join(@dir, "output") end))
      :database -> Consolidator.save()
    end

    if Keyword.get(opts, :shutdown, false) do
      Consolidator.shutdown()
    end
  end

  defp fetch_file_stream(input_dir) do
    [file_name] = File.ls!(input_dir)

    Logger.info("#{file_name} identified")

    input_dir
    |> Path.join(file_name)
    |> File.stream!(read_ahead: 100_000)
    |> NimbleCSV.Semicolon.parse_stream()
    |> Stream.with_index(1)
  end
end
