defmodule SlackFileCleaner.MixProject do
  use Mix.Project

  def project do
    [
      app: :slack_file_cleaner,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(), 
      escript: [main_module: SlackFileCleaner]
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
      {:httpoison, "~> 0.6"}, 
      {:poison, "~> 3.1"}, 
    ]
  end
end
