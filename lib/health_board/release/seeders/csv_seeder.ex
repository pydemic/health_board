defmodule HealthBoard.Release.Seeders.CSVSeeder do
  require Logger

  @app :health_board

  @spec seed(String.t(), (list() -> :ok), keyword()) :: :ok
  def seed(csv_file_path, seeder_function, opts \\ []) do
    Logger.debug("Seeding #{csv_file_path}")

    logger_level = Logger.level()
    Logger.configure(level: :warn)

    try do
      @app
      |> :code.priv_dir()
      |> Path.join("data")
      |> Path.join(csv_file_path)
      |> File.stream!()
      |> get_csv_parser(Keyword.get(opts, :csv_type)).parse_stream()
      |> stream_seeder(seeder_function, Keyword.get(opts, :sync, false))
      |> Stream.run()
    rescue
      error -> Logger.error(Exception.message(error))
    end

    Logger.configure(level: logger_level)
    Logger.info("#{csv_file_path} seeded")
  end

  defp get_csv_parser(_), do: NimbleCSV.RFC4180

  defp stream_seeder(stream, seeder_function, false), do: Task.async_stream(stream, seeder_function)
  defp stream_seeder(stream, seeder_function, _sync), do: Stream.map(stream, seeder_function)
end
