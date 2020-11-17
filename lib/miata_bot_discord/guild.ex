defmodule MiataBotDiscord.Guild do
  @moduledoc """
  Root level supervisor for every guild.
  Don't start manually - The Event source should use
  the dynamic supervisor to start this supervisor.
  """
  use Supervisor

  alias MiataBotDiscord.Guild.{
    AutoreplyConsumer,
    CarinfoConsumer
  }

  import MiataBotDiscord.Guild.Registry, only: [via: 2]

  def child_spec({guild, config, user}) do
    %{
      id: guild.id,
      start: {__MODULE__, :start_link, [{guild, config, user}]}
    }
  end

  @doc false
  def start_link({guild, config, current_user}) do
    Supervisor.start_link(__MODULE__, {guild, config, current_user})
  end

  @impl Supervisor
  def init({guild, config, current_user}) do
    children = [
      # boostrap processes
      {MiataBotDiscord.Guild.Registry, guild},
      {MiataBotDiscord.Guild.EventDispatcher, guild},

      # consumers
      {AutoreplyConsumer, {guild, config, current_user}},
      {CarinfoConsumer, {guild, config, current_user}},

      # Responder
      {MiataBotDiscord.Guild.Responder,
       {guild,
        [
          via(guild, AutoreplyConsumer),
          via(guild, CarinfoConsumer)
        ]}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
