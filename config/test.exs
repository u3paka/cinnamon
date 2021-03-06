use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cinnamon, CinnamonWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :cinnamon, Cinnamon.Repo,
  username: System.get_env("DEV_DB_USER"),
  password: System.get_env("DEV_DB_PASSWORD"),
  database: "cinnamon_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
