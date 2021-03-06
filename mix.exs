defmodule LineBuffer.Mixfile do
  use Mix.Project

  def project do
    [app: :line_buffer,
     version: "1.0.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     # Hex
     package: hex_package(),
     description: "Line buffer that breaks strings into lines",
     # Docs
     name: "LineBuffer",
     docs: [
       main: "LineBuffer",
       extras: ["README.md",],
       ],
     # Testing
     preferred_cli_env: [espec: :test],
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: []]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:espec, "~> 1.8", only: [:dev, :test]},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
    ]
  end

  defp hex_package do
    [maintainers: ["Clay Sampson"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/sampscl/line_buffer"}]
  end
end
