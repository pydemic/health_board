defmodule HealthBoard.Updaters.SARSUpdater.ConsolidatorManager do
  alias HealthBoard.Updaters.SARSUpdater.Consolidator

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  defstruct init: true,
            input_path: Path.join(@dir, "updates/sars/input"),
            output_path: Path.join(@dir, "output/sars"),
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

    today = Date.utc_today()

    for filename <- Enum.sort(File.ls!(input_path)) do
      input_path
      |> Path.join(filename)
      |> File.stream!(read_ahead: read_ahead)
      |> NimbleCSV.Semicolon.parse_stream()
      |> Stream.with_index(2)
      |> Stream.map(fn {line, line_index} -> {line, line_index, today} end)
    end
    |> Consolidator.consolidate(output_path, split_command)

    if shutdown == true do
      Consolidator.shutdown()
    end

    :ok
  end
end
