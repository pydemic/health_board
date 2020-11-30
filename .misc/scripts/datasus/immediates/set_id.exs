defmodule HealthBoard.Scripts.DATASUS.Immediates.SetID do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")

  @output_dir Path.join(@dir, "output")
  @common_output_dir Path.join(@output_dir, "common")
  @specific_output_dir Path.join(@output_dir, "specific")

  @groups [
    {"botulism", 10000},
    {"chikungunya", 10100},
    {"cholera", 10200},
    {"hantavirus", 10300},
    {"human_rabies", 10400},
    {"malaria", 10500},
    {"plague", 10600},
    {"spotted_fever", 10700},
    {"yellow_fever", 10800},
    {"zika", 10900}
  ]

  @spec run :: :ok
  def run do
    File.mkdir_p!(@common_output_dir)
    File.mkdir_p!(@specific_output_dir)

    @input_dir
    |> File.ls!()
    |> Task.async_stream(&update_file/1, timeout: :infinity)
    |> Stream.run()
  end

  defp update_file(file_name) do
    Logger.info("Updating #{file_name}")

    {_name, context_id} = Enum.find(@groups, &String.starts_with?(file_name, elem(&1, 0)))

    common_output_file_path = Path.join(@common_output_dir, file_name)
    File.rm_rf!(common_output_file_path)

    specific_output_file_path = Path.join(@specific_output_dir, file_name)
    File.rm_rf!(specific_output_file_path)

    @input_dir
    |> Path.join(file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Stream.with_index(1)
    |> Enum.each(&update_line(&1, file_name, context_id, common_output_file_path, specific_output_file_path))
  end

  defp update_line({line, line_index}, file_name, context_id, common_output_file_path, specific_output_file_path) do
    if rem(line_index, 25_000) == 0 do
      Logger.debug("Updating line #{line_index} from #{file_name}")
    end

    {base_data, line} = extract_base_data(line, file_name, context_id)
    {common_line, specific_line} = Enum.split(line, 42)

    File.write!(common_output_file_path, Enum.join(base_data ++ common_line, ",") <> "\n", [:append])
    File.write!(specific_output_file_path, Enum.join(base_data ++ specific_line, ",") <> "\n", [:append])
  end

  defp extract_base_data([location_context_id, location_id, year | line], file_name, context_id) do
    context_id = context_id + String.to_integer(location_context_id)

    if String.contains?(file_name, "weekly") do
      [week | line] = line
      {[context_id, location_id, year, week], line}
    else
      {[context_id, location_id, year], line}
    end
  end
end

HealthBoard.Scripts.DATASUS.Immediates.SetID.run()
