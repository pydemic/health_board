defmodule HealthBoard.Release.DataPuller.FluSyndrome do
  require Logger

  alias HealthBoard.Release.DataPuller.FluSyndrome.{Consolidator, Parser}

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")

  @spec consolidate :: :ok
  def consolidate do
    File.rm_rf!(@output_dir)
    File.mkdir_p!(@output_dir)

    Parser.setup()

    fetch_files_streams()
    |> Flow.from_enumerables()
    |> Flow.map(&Parser.parse/1)
    |> Flow.run()

    Logger.info("Parsing finished")

    Parser.ets_buckets()
    |> :ets.tab2list()
    |> Consolidator.consolidate()

    @output_dir
    |> File.ls!()
    |> Enum.each(&sort_and_chunk_file/1)
  end

  defp fetch_files_streams do
    files_names =
      @input_dir
      |> File.ls!()
      |> Enum.sort()
      |> Enum.with_index(1)

    Logger.info("#{Enum.count(files_names)} files identified")

    for {file_name, file_index} <- files_names do
      @input_dir
      |> Path.join(file_name)
      |> File.stream!(read_ahead: 100_000)
      |> NimbleCSV.Semicolon.parse_stream()
      |> Stream.with_index(1)
      |> Stream.map(fn {line, line_index} -> {file_index, file_name, line_index, line} end)
      |> Stream.each(&maybe_inform_progress/1)
    end
  end

  defp maybe_inform_progress({file_index, file_name, line_index, _line}) do
    if line_index == 0 and rem(file_index, 10) == 0 do
      Logger.info("Parsing file ##{file_index} (#{file_name})")
    else
      if rem(line_index, 100_000) == 0 do
        Logger.info("[##{file_index} #{file_name}] Parsing line ##{line_index}")
      end
    end
  end

  defp sort_and_chunk_file(file_name) do
    Logger.info("Sorting and chunking #{file_name}")

    file_path = Path.join(@output_dir, file_name)

    {_result, 0} = System.cmd("sort", ~w[-o #{file_path} #{file_path}])

    dir = Path.join(@output_dir, Path.basename(file_name, ".csv"))

    File.mkdir_p!(dir)

    chunk_file_path = Path.join(dir, "#{file_name}_")

    {_result, 0} = System.cmd("split", ~w[-d -a 4 -l 500000 --additional-suffix=.csv #{file_path} #{chunk_file_path}])

    File.rm!(file_path)
  end
end
