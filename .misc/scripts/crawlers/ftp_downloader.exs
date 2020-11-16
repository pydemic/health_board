defmodule HealthBoard.Scripts.Crawlers.FTPDownloader do
  require Logger

  @suffix ".dbc"

  # AIH - 2007-
  # @ftp_address 'ftp.datasus.gov.br'
  # @base_path '/dissemin/publicos/SIHSUS/199201_200712/Dados'
  # @base_file_name "RDDF"
  # @years ~w[00 01 02 03 04 05 06 07]
  # @months ~w[01 02 03 04 05 06 07 08 09 10 11 12]
  # @file_names for year <- @years, month <- @months, do: "#{@base_file_name}#{year}#{month}#{@suffix}"

  # AIH - 2008+
  # @ftp_address 'ftp.datasus.gov.br'
  # @base_path '/dissemin/publicos/SIHSUS/200801_/Dados'
  # @base_file_name "RDDF"
  # @years ~w[08 09 10 11 12 13 14 15 16 17 18 19]
  # @months ~w[01 02 03 04 05 06 07 08 09 10 11 12]
  # @file_names for year <- @years, month <- @months, do: "#{@base_file_name}#{year}#{month}#{@suffix}"

  # Immediates - Final
  @ftp_address 'ftp.datasus.gov.br'
  @base_path '/dissemin/publicos/SINAN/DADOS/FINAIS'
  @groups ~w[BOTU CHIK COLE FAMA FMAC HANT MALA PEST RAIV ZIKA]
  @states ~w[AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO]
  @years ~w[00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19]
  @file_names for g <- @groups, s <- @states, y <- @years, do: "#{g}#{s}#{y}#{@suffix}"

  # Immediates - Preliminar
  # @ftp_address 'ftp.datasus.gov.br'
  # @base_path '/dissemin/publicos/SINAN/DADOS/PRELIM'
  # @groups ~w[BOTU COLE FMAC HANT MALA PEST RAIV]
  # @states ~w[AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO]
  # @years ~w[14 15 16 17 18 19 20]
  # @file_names for g <- @groups, s <- @states, y <- @years, do: "#{g}#{s}#{y}#{@suffix}"

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @output_dir Path.join(@dir, "dbcs")

  @spec run :: :ok
  def run do
    :application.start(:inets)
    {:ok, pid} = :inets.start(:ftpc, host: @ftp_address)

    try do
      :ok = :ftp.user(pid, 'anonymous', 'anonymous')
      :ok = :ftp.type(pid, :binary)
      :ok = :ftp.cd(pid, @base_path)

      Enum.each(@file_names, &save_file(pid, &1))
    rescue
      error ->
        Logger.error(Exception.message(error) <> "\n" <> Exception.format_stacktrace(__STACKTRACE__))
    end

    :inets.stop(:ftpc, pid)
    :application.stop(:inets)
  end

  defp save_file(pid, file_name) do
    file_path = Path.join(@output_dir, file_name)

    case :ftp.recv(pid, String.to_charlist(file_name), String.to_charlist(file_path)) do
      :ok ->
        Logger.info("Successfully downloaded #{file_name}")

      {:error, reason} ->
        File.rm_rf!(file_path)
        Logger.error("Failed to download #{file_name}, reason: #{reason}")
    end
  end
end

HealthBoard.Scripts.Crawlers.FTPDownloader.run()
