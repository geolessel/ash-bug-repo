defmodule Playdate.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [Playdate.Repo]

    opts = [strategy: :one_for_one, name: Playdate.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
