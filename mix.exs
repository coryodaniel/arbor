defmodule Arbor.Mixfile do
  use Mix.Project
  @version "0.1.0"

  def project do
    [
      app: :arbor,
      description: "Ecto tree / hierarchy traversal using CTEs",
      version: @version,
      elixir: "~> 1.2",
      elixirc_paths: elixirc_paths(Mix.env),
      package: package,
      deps: deps,
      aliases: aliases,
      docs: docs,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env
    ]
  end

  def application do
    [applications: [:logger, :ecto]]
  end

  defp aliases do
    [
      "db.reset": ["ecto.drop", "ecto.create", "ecto.migrate"],
      "test": ["db.reset", "test"]
    ]
  end

  defp deps do
    [
      {:ecto, ">= 2.0.0"},
      {:postgrex, ">= 0.0.0", optional: true},

      {:dialyxir, "~> 0.3.0", only: :dev},
      {:mix_test_watch, "~> 0.2", only: :dev},

      {:earmark, "~> 1.0.1", only: [:docs, :dev]},
      {:ex_doc, "~> 0.13.0", only: [:docs, :dev]},
      
      {:excoveralls, "~> 0.5", only: :test},
      {:inch_ex, "~> 0.5", only: [:dev, :test]},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:dogma, "~> 0.1", only: [:dev, :test]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      maintainers: ["Cory O'Daniel"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/coryodaniel/arbor"},
      files: ~w(mix.exs README.md lib)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}",
      source_url: "https://github.com/coryodaniel/arbor"
    ]
  end

  defp preferred_cli_env do
    [
      "coveralls": :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end
end
