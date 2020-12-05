defmodule HealthBoard.Release.DataManager do
  require Logger

  @spec copy!(String.t(), String.t(), list(atom)) :: :ok
  def copy!(context, table_name, fields) do
    context
    |> Path.join(table_name <> ".csv")
    |> copy_from_path!(table_name, fields)
  end

  @spec copy_from_dir!(String.t(), String.t(), list(atom)) :: :ok
  def copy_from_dir!(path, table_name, fields) do
    data_path()
    |> Path.join(path)
    |> File.ls!()
    |> Enum.map(&Path.join(path, &1))
    |> Enum.each(&copy_from_path!(&1, table_name, fields))
  end

  @spec copy_from_path!(String.t(), String.t(), list(atom)) :: :ok
  def copy_from_path!(path, table_name, fields) do
    data_path()
    |> Path.join(path)
    |> copy_query(table_name, fields)
    |> HealthBoard.Repo.query!()

    :ok
  end

  defp copy_query(csv_path, table_name, fields) do
    fields = Enum.join(fields, ",")

    "COPY #{table_name}(#{fields}) FROM '#{csv_path}' WITH CSV;"
  end

  defp data_path do
    Application.get_env(:health_board, :data_path)
  end
end
