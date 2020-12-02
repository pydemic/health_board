defmodule HealthBoard.Release.Seeders.Seeder do
  require Logger

  alias HealthBoard.Repo

  @app :health_board

  @spec seed(String.t(), module(), (list(), String.t() -> list()), keyword()) :: :ok
  def seed(zip_file_path, schema, seeder_function, opts \\ []) do
    temporary_dir = String.to_charlist("/tmp/#{:os.system_time(:millisecond)}")

    try do
      logger_level = Logger.level()

      Logger.debug("Seeding #{zip_file_path}")

      @app
      |> :code.priv_dir()
      |> Path.join("data")
      |> Path.join(zip_file_path)
      |> String.to_charlist()
      |> :zip.unzip(cwd: temporary_dir)
      |> elem(1)
      |> set_logger_level(:warn)
      |> maybe_filter_files(Keyword.get(opts, :filter_files_function))
      |> Task.async_stream(&seed_each(&1, schema, seeder_function, opts), timeout: :infinity)
      |> Enum.reduce(0, &(&2 + elem(&1, 1)))
      |> set_logger_level(logger_level)
      |> inform_result(zip_file_path)

      File.rm_rf!(temporary_dir)
    rescue
      error ->
        File.rm_rf!(temporary_dir)
        reraise(error, __STACKTRACE__)
    end

    :ok
  end

  defp set_logger_level(pipeline, level) do
    Logger.configure(level: level)
    pipeline
  end

  defp maybe_filter_files(files, function) do
    if is_function(function) do
      function.(files)
    else
      files
    end
  end

  defp seed_each(csv_file_path, schema, seeder_function, opts) do
    file_name = Path.basename(csv_file_path, ".csv")

    csv_file_path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: Keyword.get(opts, :skip_headers, false))
    |> Task.async_stream(&seeder_function.(&1, file_name), timeout: :infinity)
    |> Enum.map(&elem(&1, 1))
    |> insert_all(schema, Keyword.get(opts, :batch_size, 1_000))
    |> validate_seeding!()
  end

  defp validate_seeding!(result) do
    case result do
      {:ok, summary} ->
        Enum.reduce(summary, 0, &(&2 + elem(elem(&1, 1), 0)))

      error ->
        Logger.error("Error received: #{inspect(error)}")
        raise "failed to seed"
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

  defp inform_result(amount, csv_file_path) do
    Logger.info("#{csv_file_path} seeded #{amount} elements.")
  end
end
