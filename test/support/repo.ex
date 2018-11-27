defmodule Arbor.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :arbor,
    adapter: Ecto.Adapters.Postgres
end
