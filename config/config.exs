# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :vocial,
  ecto_repos: [Vocial.Repo]

# Configures the endpoint
config :vocial, VocialWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "r9Mvl7hpKgCy3nYyQz8v1OQ8u1FKFSYVChAKZS2QUz38jJSF6iuA6d1l95hfRKVM",
  render_errors: [view: VocialWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Vocial.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user,user:email,public_repo"]}
  ]

# 对应github的oauth app  https://github.com/settings/applications/1181671
config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID") || "64a68bd4a6c9b772ccfe",
  client_secret:
    System.get_env("GITHUB_CLIENT_SECRET") || "516fe4fcc372be271b8193e5647c7a7ad09e80ee"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
