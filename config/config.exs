import Config

wildcard_import = fn wildcard ->
  for config <- wildcard |> Path.expand(__DIR__) |> Path.wildcard() do
    import_config config
  end
end

wildcard_import.("general/*.exs")
wildcard_import.("#{Mix.env()}/*.exs")

override_file_path = Path.expand("override.exs", __DIR__)

if File.exists?(override_file_path) do
  import_config override_file_path
end
