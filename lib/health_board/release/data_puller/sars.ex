defmodule HealthBoard.Release.DataPuller.SARS do
  require Logger

  alias HealthBoard.Release.DataPuller.SARS.Consolidator

  @app :health_board
  @input_path "/tmp"
  @output_path Path.join(File.cwd!(), ".misc/data")

  @spec consolidate() :: :ok
  def consolidate do
    Consolidator.setup()

    @input_path
    |> Path.join("sivep_srag")
    |> fetch_files_streams()
    |> Flow.from_enumerables()
    |> Flow.map(&Consolidator.parse/1)
    |> Flow.run()

    Logger.info("Parsing finished")

    output_dir = Path.join(@output_path, "sars")
    File.rm_rf!(output_dir)
    File.mkdir_p!(output_dir)

    Consolidator.write(output_dir)

    output_dir
    |> File.ls!()
    |> Enum.each(&sort_and_chunk_file(&1, output_dir))
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

  defp sort_and_chunk_file(file_name, output_dir) do
    name = Path.basename(file_name, ".csv")

    Logger.info("Sorting and chunking #{name}")

    file_path = Path.join(output_dir, file_name)

    {_result, 0} = System.cmd("sort", ~w[-o #{file_path} #{file_path}])

    dir = Path.join(output_dir, Path.basename(file_name, ".csv"))

    File.mkdir_p!(dir)

    chunk_file_path = Path.join(dir, "#{name}_")

    {_result, 0} =
      System.cmd(
        Application.fetch_env!(@app, :split_command),
        ~w[-d -a 4 -l 500000 --additional-suffix=.csv #{file_path} #{chunk_file_path}]
      )

    File.rm!(file_path)

    if Enum.count(File.ls!(dir)) == 1 do
      File.rename!(Path.join(dir, "#{name}_0000.csv"), file_path)
      File.rmdir!(dir)
    end
  end
end
