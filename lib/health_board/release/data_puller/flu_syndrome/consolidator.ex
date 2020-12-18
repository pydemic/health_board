defmodule HealthBoard.Release.DataPuller.FluSyndrome.Consolidator do
  def consolidate(daily_records) do
    IO.inspect(Enum.count(daily_records))
    IO.inspect(Enum.at(daily_records, 0))
  end
end
