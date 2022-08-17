defmodule IslandsGame.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        paths: ["_build/dev/lib/islands_engine/ebin", "_build/dev/lib/islands_interface/ebin"]
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false}
    ]
  end
end
