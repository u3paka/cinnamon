defmodule Cinnamon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Cinnamon.Repo,
      # Start the endpoint when the application starts
      CinnamonWeb.Endpoint,
      Mantra.Supervisor,
      # Starts a worker by calling: Cinnamon.Worker.start_link(arg)
      {Cinnamon.BotWorker, [[]]},
      #1. Initialize Bot in main Supervisor proccess as child.
      #2. Tell main supervisor to monitor Child supervisor MyApp.Bot.
      #3. Assign it a name as `Slack.Supervisor`
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cinnamon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CinnamonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
