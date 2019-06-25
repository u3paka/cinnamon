# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :cinnamon,
  ecto_repos: [Cinnamon.Repo]

# Configures the endpoint
config :cinnamon, CinnamonWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Dyo+OScGcOxNQrMZ+3Xs3dfK+VjhkoqGX5O+j9uSO7Dwd7H+r1/NYFNnJn5+Lw0t",
  render_errors: [view: CinnamonWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Cinnamon.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :slack,
  api_token: System.get_env("SLACK_TOKEN")
config :cinnamon,
  slack_token: System.get_env("SLACK_TOKEN")
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
