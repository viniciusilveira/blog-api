# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :blog,
  ecto_repos: [Blog.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :blog, BlogWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2Ne5wE+NXdar+ic5tnDabkrAHpr8vvYVY67VjoF1HXidLWdAZPMaF/1Dz++dE7KA",
  render_errors: [view: BlogWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Blog.PubSub,
  live_view: [signing_salt: "0pIuLu9b"]

config :blog, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: BlogWeb.Router,
      endpoint: BlogWeb.Endpoint
    ]
  }

config :phoenix_swagger, json_library: Jason

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
