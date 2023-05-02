defmodule SkyModsWeb.AccountsComponents do
  @moduledoc """
    Components to render data from the accounts context.
  """

  alias SkyMods.Accounts.User

  use Phoenix.Component

  attr :user, User, required: true

  def user_bio(assigns) do
    ~H"""
    <div class="flex flex-col justify-center items-center">
      <.user_avatar user={@user} />

      <h1 class="font-bold text-lg mb-4">
        <%= @user.username %>
        <span class="text-zinc-600">#<%= @user.id %></span>
      </h1>

      <p class="italic">
        <%= @user.bio %>
      </p>
    </div>
    """
  end

  def user_avatar(assigns) do
    ~H"""
    <img
      src={"/images/#{@user.avatar}"}
      class="max-w-xs rounded-full ring ring-6 ring-black ring-offset-2 mb-10"
    />
    """
  end
end
