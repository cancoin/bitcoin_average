defmodule BitcoinAverage.Mixfile do
  use Mix.Project

  def project do
    [app: :bitcoin_average,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :ibrowse, :httpotion, :exjsx, :gun],
     mod: {BitcoinAverage, []}]
  end

  defp deps do
    [
      {:httpotion, "~> 3.0.2"},
      {:ibrowse, "~> 4.2"},
      {:exjsx, "~> 3.2.1"},
      {:gun, "~> 1.0.0-pre.1"}
    ]
  end
end
