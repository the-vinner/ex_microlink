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
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/the-vinner/ex_microlink"
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
      {:html_sanitize_ex, ">= 1.4.2"},
      {:req, ">= 0.2.1"},
      {:typed_struct, ">= 0.2.1"}
    ]
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib priv .formatter.exs mix.exs README* readme* LICENSE*
                license* CHANGELOG* changelog* src),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/the-vinner/ex_microlink"}
    ]
  end
end
