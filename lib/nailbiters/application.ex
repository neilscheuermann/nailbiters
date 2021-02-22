defmodule Nailbiters.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Nailbiters.Repo,
      # Start the endpoint when the application starts
      NailbitersWeb.Endpoint,
      # Starts a worker by calling: Nailbiters.Worker.start_link(arg)
      # {Nailbiters.Worker, arg},
      # Start a GenServer to fetch NBA data every 15 seconds.
      Nailbiters.Periodically
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nailbiters.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NailbitersWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
