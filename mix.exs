defmodule Noaa.MixProject do
  use Mix.Project

  def project do
    [
      app: :noaa,
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.8",
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
      # http client
      {:httpoison, "~> 1.5.0"},
      # parser
      {:poison, "~> 3.1.0"},
      # documentation tool
      {:ex_doc, "~> 0.19.3"},
      # markdown-to-html converter
      {:earmark, "~> 1.3.1"}
    ]
  end

  defp escript_config do
    [
      main_module: Noaa.CLI
    ]
  end
end
