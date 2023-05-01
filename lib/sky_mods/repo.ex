defmodule SkyMods.Repo do
  use Ecto.Repo,
    otp_app: :sky_mods,
    adapter: Ecto.Adapters.SQLite3
end
