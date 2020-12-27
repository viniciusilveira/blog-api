use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :blog, BlogWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :blog, Blog.Guardian,
  issuer: "blog",
  secret_key: "teuO4kXNDKsgvd8rxG1UiA+l+Ndt0bT5RaBOYerzWRHvgiO2FkCsfpqmPA29k5ps"

import_config "db/#{Mix.env()}.secret.exs"
