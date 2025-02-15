import Config

config :playdate, Playdate.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "playdate_dev",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
