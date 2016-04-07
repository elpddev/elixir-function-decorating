defmodule FunctionDecorating.Mixfile do
  use Mix.Project

  def project do
    [app: :function_decorating,
     version: "0.0.2",
     name: "Function Decorating", 
     source_url: "https://github.com/elpddev/elixir-function-decorating",
     homepage_url: "https://github.com/elpddev/elixir-function-decorating",
     elixir: "~> 1.2",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     docs: [extras: ["README.md"]
     ]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  defp description do
    """
    A function decorator macro for Elixir.
    Used mainly for adding log statements to the function calls.
    """
  end

  defp package do
    [
      maintainers: ["Eyal Lapid"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/elpddev/elixir-function-decorating"}
    ]
  end
end
