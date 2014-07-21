defmodule Phoenix.Mixfile do
  use Mix.Project

  def project do
    [
      app: :phoenix,
      version: "0.3.1",
      elixir: "~> 0.14.2",
      deps: deps(Mix.env),
      package: [
        contributors: ["Chris McCord", "Darko Fabijan"],
        licenses: ["MIT"],
        links: [github: "https://github.com/phoenixframework/phoenix"]
      ],
      description: """
      Elixir Web Framework targeting full-featured, fault tolerant applications
      with realtime functionality
      """
    ]
  end

  def application do
    [
      mod: { Phoenix, [] },
      applications: [:cowboy, :plug]
    ]
  end

  defp deps(:prod) do
    [
      {:cowboy, "~> 0.10.0", github: "extend/cowboy", optional: true},
      {:plug, "0.5.2"},
      {:inflex, "0.2.4"},
      {:linguist, "~> 0.1.0"},
      {:jazz, "0.1.2"},
      {:calliope, github: "nurugger07/calliope"}
    ]
  end

  defp deps(_) do
    deps(:prod) ++
      [ {:ex_doc, github: "elixir-lang/ex_doc", only: [:docs]} ]
  end
end
