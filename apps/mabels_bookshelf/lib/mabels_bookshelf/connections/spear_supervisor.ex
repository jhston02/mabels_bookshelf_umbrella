defmodule MabelsBookshelf.Connections.SpearSupervisor do
  use Supervisor

  defp poolboy_config do
    [
      name: {:local, :spear_supervisor},
      worker_module: Spear.Connection,
      size: 10,
      max_overflow: 2
    ]
  end

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      :poolboy.child_spec(:spear_supervisor, poolboy_config())
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
