defmodule HealthBoard.Release.DataPuller.ICUOccupancy do
  require Logger

  alias HealthBoard.Release.DataPuller.ICUOccupancy.Consolidator

  @output_path Path.join(File.cwd!(), ".misc/data")

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
    |> Keyword.get(:spreadsheet)
    |> Flow.from_enumerable()
    |> Flow.map(&Consolidator.parse(&1, after_date))
    |> Flow.run()

    Logger.info("Parsing finished")

    case Keyword.get(opts, :type, :file) do
      :file ->
        Consolidator.write(Keyword.get_lazy(opts, :output_dir, fn -> Path.join(@output_path, "icu_occupancy") end))

      :database ->
        Consolidator.save()
    end

    if Keyword.get(opts, :shutdown, false) do
      Consolidator.shutdown()
    end
  end
end
