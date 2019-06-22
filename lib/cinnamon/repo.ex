defmodule Cinnamon.Repo do
  use Ecto.Repo,
    otp_app: :cinnamon,
    adapter: Ecto.Adapters.Postgres
end
