defmodule Nailbiters.Repo do
  use Ecto.Repo,
    otp_app: :nailbiters,
    adapter: Ecto.Adapters.Postgres
end
