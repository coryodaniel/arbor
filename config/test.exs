use Mix.Config

config :arbor, ecto_repos: [Arbor.Repo]

config :arbor, Arbor.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "arbor_test",
  username: System.get_env("ARBOR_DB_USER") || System.get_env("USER")

config :logger, :console, level: :error
