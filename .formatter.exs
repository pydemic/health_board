[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test,.misc}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"],
  line_length: 120
]
