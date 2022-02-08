import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mabels_bookshelf_web, MabelsBookshelfWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ydavan78yvFqEju0v+Vneq7slRdYAZhuc4cUJyKVo68BQIoshjdKoaf+K0oD9BFR",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# In test we don't send emails.
config :mabels_bookshelf, MabelsBookshelf.Mailer, adapter: Swoosh.Adapters.Test

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
