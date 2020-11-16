defmodule HealthBoard.Scripts.DATASUS.Immediates.Zipper do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @immediates_dir Path.join(@dir, "immediates")

  @diseases ~w[
    botulism chikungunya cholera hantavirus human_rabies malaria_from_amazon plague spotted_fever yellow_fever zika
  ]

  @date_types ~w[daily yearly]

  @contexts ~w[resident source]

  @spec run :: :ok
  def run do
    for d <- @diseases, dt <- @date_types, c <- @contexts do
      @immediates_dir
      |> Path.join("#{d}/#{dt}/#{c}")
      |> File.cd!()

      Enum.each(File.ls!(), &zip_dir_and_delete/1)
    end
  end

  defp zip_dir_and_delete(geo_context) do
    System.cmd("zip", ["-r", "#{geo_context}.zip", geo_context])
    File.rm_rf!(geo_context)
  end
end

HealthBoard.Scripts.DATASUS.Immediates.Zipper.run()
