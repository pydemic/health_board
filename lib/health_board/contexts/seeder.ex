defmodule HealthBoard.Contexts.Seeder do
  alias HealthBoard.Repo
  require Logger

  @spec csv_from_context!(String.t(), String.t(), list(atom), String.t() | nil) :: :ok
  def csv_from_context!(context, table_name, fields, base_path \\ nil) do
    base_path
    |> Kernel.||(data_path())
    |> Path.join(context)
    |> Path.join(table_name <> ".csv")
    |> csv_from_file_path!(table_name, fields)
  end

  @spec csvs_from_context!(String.t(), String.t(), list(atom), String.t() | nil) :: :ok
  def csvs_from_context!(context, table_name, fields, base_path \\ nil) do
    context
    |> Path.join(table_name)
    |> csvs_from_path!(table_name, fields, base_path)
  end

  @spec csvs_from_path!(String.t(), String.t(), list(atom), String.t() | nil) :: :ok
  def csvs_from_path!(path, table_name, fields, base_path \\ nil) do
    root_path = Path.join(base_path || data_path(), path)

    root_path
    |> File.ls!()
    |> Enum.sort()
    |> Enum.each(fn name ->
      current_path = Path.join(root_path, name)

      if File.dir?(current_path) do
        path
        |> Path.join(name)
        |> csvs_from_path!(table_name, fields, base_path)
      else
        csv_from_file_path!(current_path, table_name, fields)
      end
    end)
  end

  @spec csv_from_file_path!(String.t(), String.t(), list(atom)) :: :ok
  def csv_from_file_path!(path, table_name, fields) do
    dirname = Path.basename(Path.dirname(path))
    filename = Path.basename(path, ".csv")

    Logger.info("Seeding #{dirname} (#{filename}) for table #{table_name}")

    path
    |> csv_copy_query(table_name, fields)
    |> Repo.query!([], timeout: :infinity)

    :ok
  end

  defp csv_copy_query(csv_path, table_name, fields) do
    fields =
      fields
      |> Enum.map(fn field -> ~s("#{field}") end)
      |> Enum.join(",")

    "COPY #{table_name}(#{fields}) FROM '#{csv_path}' WITH CSV;"
  end

  defp data_path do
    Application.fetch_env!(:health_board, :data_path)
  end

  @spec down!(String.t()) :: :ok
  def down!(table_name) do
    Repo.query!("TRUNCATE #{table_name} CASCADE;", [], timeout: :infinity)
    :ok
  end
end
