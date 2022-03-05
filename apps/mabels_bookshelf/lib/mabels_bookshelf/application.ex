defmodule MabelsBookshelf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: MabelsBookshelf.PubSub},
      MabelsBookshelf.EventStoreDbClient
      # Start a worker by calling: MabelsBookshelf.Worker.start_link(arg)
      # {MabelsBookshelf.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MabelsBookshelf.Supervisor)
  end
end
