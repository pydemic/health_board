defmodule HealthBoard.Updaters.FluSyndromeUpdater.Extractor do
  use GenServer, restart: :permanent

  require Logger

  @spec add({atom | String.t(), list(any)}) :: :ok
  def add({name, line}), do: GenServer.cast(__MODULE__, {:add, name, line})

  @spec add(atom | String.t(), list(any)) :: :ok
  def add(name, line), do: GenServer.cast(__MODULE__, {:add, name, line})

  @spec create(atom | String.t(), list(any)) :: :ok
  def create(name, headers), do: GenServer.cast(__MODULE__, {:create, name, headers})

  @spec clear :: :ok
  def clear, do: GenServer.cast(__MODULE__, :clear)

  @spec dump :: :ok
  def dump, do: GenServer.cast(__MODULE__, :dump)

  @spec set_output_path(String.t()) :: :ok
  def set_output_path(output_path), do: GenServer.cast(__MODULE__, {:set_output_path, output_path})

  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    GenServer.start(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  @spec init(keyword) :: {:ok, {map, map}}
  def init(args) do
    path = Keyword.get(args, :path, Path.join(File.cwd!(), ".misc/sandbox/updates/flu_syndrome"))

    {:ok,
     {
       %{
         chunk_size: Keyword.get(args, :chunk_size, 200_000),
         path: Path.join(path, "output/extractions")
       },
       %{}
     }}
  end

  @impl GenServer
  @spec handle_cast(any, {map, map}) :: {:noreply, {map, map}}
  def handle_cast({:add, name, line}, {settings, extractions}) do
    case Map.fetch(extractions, name) do
      {:ok, {size, data}} ->
        if size >= settings.chunk_size do
          settings.path
          |> Path.join("#{name}.csv")
          |> File.write!(NimbleCSV.RFC4180.dump_to_iodata(data), [:append, :utf8])

          {:noreply, {settings, Map.delete(extractions, name)}}
        else
          {:noreply, {settings, Map.put(extractions, name, {size + 1, [line | data]})}}
        end

      _result ->
        {:noreply, {settings, Map.put(extractions, name, {1, [line]})}}
    end
  end

  def handle_cast({:create, name, headers}, {%{path: path}, _extractions} = state) do
    file_path = Path.join(path, "#{name}.csv")
    File.rm_rf!(file_path)
    File.write!(file_path, NimbleCSV.RFC4180.dump_to_iodata([headers]), [:utf8])
    {:noreply, state}
  end

  def handle_cast(:clear, {%{path: path} = settings, _extractions}) do
    File.rm_rf!(path)
    File.mkdir_p!(path)
    {:noreply, {settings, %{}}}
  end

  def handle_cast(:dump, {%{path: path} = settings, extractions}) do
    Enum.each(extractions, fn {name, {_size, data}} ->
      path
      |> Path.join("#{name}.csv")
      |> File.write!(NimbleCSV.RFC4180.dump_to_iodata(data), [:append, :utf8])
    end)

    Enum.each(File.ls!(path), fn filename ->
      file_path = Path.join(path, Path.basename(filename, ".csv"))
      {_result, 0} = System.cmd("zip", ~w(#{file_path} #{file_path}.csv))
    end)

    {:noreply, {settings, %{}}}
  end

  def handle_cast({:set_output_path, output_path}, {settings, extractions}) do
    {:noreply, {Map.put(settings, :path, Path.join(output_path, "extractions")), extractions}}
  end
end
