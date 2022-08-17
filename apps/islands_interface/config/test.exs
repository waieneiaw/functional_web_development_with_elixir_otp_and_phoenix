import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :islands_interface, IslandsInterfaceWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "gbM3JXCD2u1VDz/lL/KYhzenfbWTlfH71FHah5EDuVWr9eU9KYFrsXXifvW76p+t",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
