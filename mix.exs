defmodule SharedState.MixProject do
  use Mix.Project

  def project do
    [
      app: :shared_state,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:mix_readme, "~> 0.1", only: :dev, runtime: false}
    ]
  end
end
