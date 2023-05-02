defmodule SkyModsWeb.ProfileLive do
  use SkyModsWeb, :live_view

  alias SkyMods.Accounts

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => raw_id}, _uri, socket) do
    case Integer.parse(raw_id) do
      {id, _} ->
        {:noreply, assign(socket, :target, Accounts.get_user(id))}

      :error ->
        {:noreply, assign(socket, :target, nil)}
    end
  end

  def render(assigns) do
    ~H"""
    <h1 :if={@target == nil}>not found</h1>

    <div :if={@target}>
      <%= @target.username %>
    </div>
    """
  end
end
