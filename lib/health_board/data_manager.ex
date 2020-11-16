defmodule HealthBoard.DataManager do
  require Logger

  @spec copy!(String.t(), String.t(), list(atom)) :: :ok
  def copy!(context, table_name, fields) do
    context
    |> copy_query(table_name, fields)
    |> HealthBoard.Repo.query!()

    :ok
  end

  defp copy_query(context, table_name, fields) do
    fields = Enum.join(fields, ",")

    "COPY #{table_name}(#{fields}) FROM '#{path(context, table_name)}' WITH CSV;"
  end

  defp data_path do
    Application.get_env(:health_board, :data_path)
  end

  defp path(context, table_name) do
    Path.join(data_path(), Path.join(context, table_name <> ".csv"))
  end
end
