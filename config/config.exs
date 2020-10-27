import Config

wildcard_import = fn wildcard ->
  for config <- wildcard |> Path.expand(__DIR__) |> Path.wildcard() do
    import_config config
  end
end

wildcard_import.("general/*.exs")
wildcard_import.("#{Mix.env()}/*.exs")
