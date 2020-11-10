defmodule HealthBoard.Scripts.DATASUS.SINASC.ZipData do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @results_dir Path.join(@dir, "results/demographic/births")
  @groups ["resident", "source"]

  @spec run :: :ok
  def run do
    Enum.each(@groups, &zip_from_group/1)
  end

  defp zip_from_group(group) do
    @results_dir
    |> Path.join(group)
    |> File.ls!()
    |> inform_files_from_group(group)
    |> Enum.each(&zip_dir(&1, group))
  end

  defp inform_files_from_group(dirs, group) do
    Logger.info("#{Enum.count(dirs)} directories identified from #{group}")
    dirs
  end

  defp zip_dir(group_dir, group) do
    dir =
      @results_dir
      |> Path.join(group)
      |> Path.join(group_dir)

    files =
      dir
      |> File.ls!()
      |> Enum.map(&String.to_charlist(Path.join(dir, &1)))

    {:ok, _file_path} = :zip.zip(String.to_charlist("#{dir}.zip"), files)
  end
end

HealthBoard.Scripts.DATASUS.SINASC.ZipData.run()
