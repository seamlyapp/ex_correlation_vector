defmodule CorrelationVector.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_correlation_vector,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/seamlyapp/ex_correlation_vector",
      description: description(),
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  def docs() do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  def description() do
    "CorrelationVector provides the Elixir implementation of the Microsoft CorrelationVector protocol"
  end

  def package() do
    [
      name: "ex_correlation_vector",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/seamlyapp/ex_correlation_vector"}
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
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
