defmodule ExMicrolink.MixProject do
  use Mix.Project

  defp description() do
    "A simple Elixir-based API wrapper for Microlink (https://microlink.io/)"
  end

  def project do
    [
      app: :ex_microlink,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, ">= 3.7.1"},
      {:html_sanitize_ex, ">= 1.3.0-rc3"},
      {:req, ">= 0.2.1"},
      {:typed_struct, ">= 0.2.1"}
    ]
  end
end
