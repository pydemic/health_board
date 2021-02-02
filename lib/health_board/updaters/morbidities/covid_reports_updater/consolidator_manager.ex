defmodule HealthBoard.Updaters.CovidReportsUpdater.ConsolidatorManager do
  alias HealthBoard.Updaters.CovidReportsUpdater.Consolidator

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  defstruct init: true,
            input_path: Path.join(@dir, "input/covid_reports"),
            output_path: Path.join(@dir, "output/consolidations"),
            read_ahead: 100_000,
            setup: false,
            shutdown: false,
            split_command: "split"

  @spec consolidate(keyword) :: :ok
  def consolidate(opts \\ []) do
    %{
      init: init,
      input_path: input_path,
      output_path: output_path,
      read_ahead: read_ahead,
      setup: setup,
      shutdown: shutdown,
      split_command: split_command
    } = struct(__MODULE__, opts)

    if init == true do
      Consolidator.init()
    end

    if setup == true do
      Consolidator.setup()
    end

    [file_name] = File.ls!(input_path)

    file_name
    |> File.stream!(read_ahead: read_ahead)
    |> NimbleCSV.Semicolon.parse_stream()
    |> Consolidator.consolidate(output_path, split_command)

    if shutdown == true do
      Consolidator.shutdown()
    end

    :ok
  end
end
