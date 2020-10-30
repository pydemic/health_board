defmodule HealthBoard.Release.Seeders.InsertAllCSVSeeder do
  require Logger

  alias HealthBoard.Repo

  @app :health_board

  @spec seed(String.t(), module(), (list() -> list()), keyword()) :: :ok
  def seed(csv_file_path, schema, seeder_function, opts \\ []) do
    Logger.debug("Seeding #{csv_file_path}")

    logger_level = Logger.level()

    @app
    |> :code.priv_dir()
    |> Path.join("data")
    |> Path.join(csv_file_path)
    |> File.stream!()
    |> get_csv_parser(Keyword.get(opts, :csv_type)).parse_stream()
    |> set_logger(:warn)
    |> stream_seeder(seeder_function, Keyword.get(opts, :sync, false))
    |> Enum.map(&parse_stream/1)
    |> insert_all(schema, Keyword.get(opts, :batch_size, 1_000))
    |> set_logger(logger_level)
    |> validate_result(csv_file_path)
  end

  defp get_csv_parser(_), do: NimbleCSV.RFC4180

  defp stream_seeder(stream, seeder_function, false), do: Task.async_stream(stream, seeder_function)
  defp stream_seeder(stream, seeder_function, _sync), do: Stream.map(stream, seeder_function)

  defp parse_stream(result) do
    if is_tuple(result) do
      elem(result, 1)
    else
      result
    end
  end

  defp insert_all(data, schema, batch_size) do
    data
    |> Enum.chunk_every(batch_size)
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), &insert_batch(&1, &2, schema))
    |> Repo.transaction()
  end

  defp insert_batch({batch, index}, multi, schema) do
    Ecto.Multi.insert_all(multi, "insert_all_#{index}", schema, batch)
  end

  defp set_logger(result, logger_level) do
    Logger.configure(level: logger_level)
    result
  end

  defp validate_result(result, csv_file_path) do
    case result do
      {:ok, summary} ->
        amount = Enum.reduce(summary, 0, &(&2 + elem(elem(&1, 1), 0)))
        Logger.info("#{csv_file_path} seeded #{amount} elements.")

      error ->
        Logger.error("#{csv_file_path} failed to seed. Error is: #{IO.inspect(error)}")
    end
  end
end
