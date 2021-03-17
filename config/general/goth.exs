import Config

with {:ok, json} <- File.read(Path.join(File.cwd!(), ".misc/data/gcloud/service_account.json")) do
  config :goth, json: json
end
