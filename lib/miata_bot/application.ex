defmodule MiataBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      PastebinRandomizer,
      # Start the Ecto repository
      MiataBot.Repo,
      MiataBot.CopyPastaWorker,
      # Start the endpoint when the application starts
      {Phoenix.PubSub, [name: MiataBot.PubSub, adapter: Phoenix.PubSub.PG2]},
      MiataBotWeb.Endpoint,
      MiataBotWeb.HerokuTask,
      MiataBotDiscord.Supervisor
      # Starts a worker by calling: MiataBot.Worker.start_link(arg)
      # {MiataBot.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MiataBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MiataBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
