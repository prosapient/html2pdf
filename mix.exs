defmodule HTML2PDF.MixProject do
  use Mix.Project

  def project do
    [
      app: :html2pdf,
      version: "0.1.0",
      elixir: "~> 1.11",
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
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.24", only: :dev}
    ]
  end
end
