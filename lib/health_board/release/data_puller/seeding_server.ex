defmodule HealthBoard.Release.DataPuller.SeedingServer do
  alias HealthBoard.Contexts.Info.Source
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  use GenServer

  require Logger

  @name :seeding_server

  @schema Source

  # Client Interface

  def start_link(_arg) do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def insert_queue(type, last_update_date) do
    GenServer.cast(@name, {type, last_update_date})
  end

  # Server Callbacks

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_cast(message, state) do
    case message do
      {:sars, last_update_date} -> do_sars_seed(last_update_date)
      {:situation_report, last_update_date} -> do_situation_report_seed(last_update_date)
      {:flu_syndrome, last_update_date} -> do_flu_syndrome_seed(last_update_date)
    end

    {:noreply, state}
  end

  @source_id_sars "sivep_srag"

  defp do_sars_seed(last_update_date) do
    Logger.info("Starting SARS seed")

    DataManager.SARS.reseed()

    do_update_date(last_update_date, @schema, @source_id_sars)

    Logger.info("SARS seed is finished")
  end

  defp do_update_date(last_update_date, schema, source_id) do
    Logger.info("Updating date for schema: #{schema}")
    source = Repo.get!(schema, source_id)

    source =
      Ecto.Changeset.change(source, %{
        last_update_date: last_update_date,
        extraction_date: Date.utc_today()
      })

    case Repo.update(source) do
      {:ok, _struct} -> {:ok, :fileds_was_updated}
      {:error, _changeset} -> {:error, :error_during_update_date}
    end
  end

  @source_id_situation_report "health_board_situation_report"

  defp do_situation_report_seed(last_update_date) do
    Logger.info("Starting Situation Report seed")

    DataManager.SituationReport.reseed()

    do_update_date(last_update_date, @schema, @source_id_situation_report)

    Logger.info("Situation Report seed is finished")
  end

  @source_id_flu_syndrome "e_sus_sg"

  defp do_flu_syndrome_seed(last_update_date) do
    Logger.info("Starting Flu Syndrome seed")

    DataManager.FluSyndrome.reseed()

    do_update_date(last_update_date, @schema, @source_id_flu_syndrome)

    Logger.info("Flu Syndrome seed is finished")
  end
end
