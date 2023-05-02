defmodule SkyModsWeb.HomeLive do
  use SkyModsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Welcome to Sky-mods!</h1>
    """
  end
end
