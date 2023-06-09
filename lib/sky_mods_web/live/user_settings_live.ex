defmodule SkyModsWeb.UserSettingsLive do
  use SkyModsWeb, :live_view

  alias SkyMods.Accounts
  alias SkyModsWeb.AccountsComponents

  def render(assigns) do
    ~H"""
    <AccountsComponents.user_bio user={@current_user} />

    <.config_list />

    <.update_email_modal
      live_action={@live_action}
      email_form={@email_form}
      email_form_current_password={@email_form_current_password}
    />

    <.update_username_modal
      live_action={@live_action}
      username_form={@username_form}
      username_form_current_password={@username_form_current_password}
      trigger_submit={@trigger_submit}
    />

    <.update_bio_modal
      live_action={@live_action}
      bio_form={@bio_form}
      trigger_submit={@trigger_submit}
    />

    <.update_password_modal
      live_action={@live_action}
      password_form={@password_form}
      current_email={@current_email}
      current_password={@current_password}
      current_username={@current_username}
      trigger_submit={@trigger_submit}
    />
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_, _, socket) do
    {:noreply, add_forms_with_user(socket, socket.assigns.current_user)}
  end

  def handle_event("validate_bio", %{"user" => update}, socket) do
    form =
      socket.assigns.current_user
      |> Accounts.change_user_bio(update)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, bio_form: form)}
  end

  def handle_event("update_bio", %{"user" => update}, socket) do
    next_socket =
      case Accounts.update_user_bio(socket.assigns.current_user, update) do
        {:ok, user} -> socket |> add_forms_with_user(user) |> push_patch(to: ~p"/users/settings")
        {:error, changeset} -> assign(socket, bio_form: to_form(changeset))
      end

    {:noreply, next_socket}
  end

  def handle_event("validate_username", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    username_form =
      socket.assigns.current_user
      |> Accounts.change_user_username(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply,
     assign(socket, username_form: username_form, username_form_current_password: password)}
  end

  def handle_event("update_username", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_username(user, password, user_params) do
      {:ok, applied_user} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "successfully updated username")
          |> assign(email_form_current_password: nil)
          |> add_forms_with_user(applied_user)
          |> push_patch(to: ~p"/users/settings")
        }

      {:error, changeset} ->
        {:noreply, assign(socket, :username_form, to_form(changeset))}
    end
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def config_list(assigns) do
    ~H"""
    <ul class="my-10 bg-white p-5 shadow rounded-md">
      <li class="flex items-center mb-2 border-b pb-2">
        Username
        <.link patch={~p"/users/settings/update_username"} class="ml-auto">
          <.button>
            <.icon name="hero-pencil" />
          </.button>
        </.link>
      </li>

      <li class="flex items-center mb-2 border-b pb-2">
        Email
        <.link patch={~p"/users/settings/update_email"} class="ml-auto">
          <.button>
            <.icon name="hero-pencil" />
          </.button>
        </.link>
      </li>

      <li class="flex items-center mb-2 border-b pb-2">
        Password
        <.link patch={~p"/users/settings/update_password"} class="ml-auto">
          <.button>
            <.icon name="hero-pencil" />
          </.button>
        </.link>
      </li>

      <li class="flex items-center mb-2 border-b pb-2">
        Avatar image
        <.link patch={~p"/users/settings"} class="ml-auto">
          <.button>
            <.icon name="hero-pencil" />
          </.button>
        </.link>
      </li>

      <li class="flex items-center">
        Bio
        <.link patch={~p"/users/settings/update_bio"} class="ml-auto">
          <.button>
            <.icon name="hero-pencil" />
          </.button>
        </.link>
      </li>
    </ul>
    """
  end

  def update_email_modal(assigns) do
    ~H"""
    <.modal
      :if={@live_action == :update_email}
      id="update-email-modal"
      on_cancel={JS.patch(~p"/users/settings")}
      show
    >
      <.simple_form
        for={@email_form}
        id="email_form"
        phx-submit="update_email"
        phx-change="validate_email"
      >
        <.input field={@email_form[:email]} type="email" label="Email" required />
        <.input
          field={@email_form[:current_password]}
          name="current_password"
          id="current_password_for_email"
          type="password"
          label="Current password"
          value={@email_form_current_password}
          required
        />
        <:actions>
          <.button phx-disable-with="Changing...">Change Email</.button>
        </:actions>
      </.simple_form>
    </.modal>
    """
  end

  def update_password_modal(assigns) do
    ~H"""
    <.modal
      :if={@live_action == :update_password}
      id="update-email-modal"
      on_cancel={JS.patch(~p"/users/settings")}
      show
    >
      <.simple_form
        for={@password_form}
        id="password_form"
        action={~p"/users/log_in?_action=password_updated"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
      >
        <.input
          field={@password_form[:email]}
          type="hidden"
          id="hidden_user_email"
          value={@current_email}
        />
        <.input
          field={@password_form[:username]}
          type="hidden"
          id="username_user_email"
          value={@current_username}
        />
        <.input field={@password_form[:password]} type="password" label="New password" required />
        <.input
          field={@password_form[:password_confirmation]}
          type="password"
          label="Confirm new password"
        />
        <.input
          field={@password_form[:current_password]}
          name="current_password"
          type="password"
          label="Current password"
          id="current_password_for_password"
          value={@current_password}
          required
        />
        <:actions>
          <.button phx-disable-with="Changing...">Change Password</.button>
        </:actions>
      </.simple_form>
    </.modal>
    """
  end

  def update_username_modal(assigns) do
    ~H"""
    <.modal
      :if={@live_action == :update_username}
      id="update-username-modal"
      on_cancel={JS.patch(~p"/users/settings")}
      show
    >
      <.simple_form
        for={@username_form}
        id="username_form"
        method="post"
        phx-change="validate_username"
        phx-submit="update_username"
        phx-trigger-action={@trigger_submit}
      >
        <.input
          field={@username_form[:username]}
          type="text"
          label="Username"
          autocomplete="off"
          required
        />
        <.input
          field={@username_form[:current_password]}
          name="current_password"
          id="current_password_for_email"
          type="password"
          label="Current password"
          value={@username_form_current_password}
          required
        />

        <:actions>
          <.button phx-disable-with="Changing...">Change Username</.button>
        </:actions>
      </.simple_form>
    </.modal>
    """
  end

  def update_bio_modal(assigns) do
    ~H"""
    <.modal
      :if={@live_action == :update_bio}
      id="update-bio-modal"
      on_cancel={JS.patch(~p"/users/settings")}
      show
    >
      <.simple_form
        for={@bio_form}
        id="bio-form"
        method="post"
        phx-change="validate_bio"
        phx-submit="update_bio"
        phx-trigger-action={@trigger_submit}
      >
        <.input field={@bio_form[:bio]} type="textarea" label="bio" autocomplete="off" required />

        <:actions>
          <.button phx-disable-with="Changing...">Change bio</.button>
        </:actions>
      </.simple_form>
    </.modal>
    """
  end

  def add_forms_with_user(socket, user) do
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    username_changeset = Accounts.change_user_username(user)
    bio_changeset = Accounts.change_user_bio(user)

    socket
    |> assign(:current_password, nil)
    |> assign(:email_form_current_password, nil)
    |> assign(:username_form_current_password, nil)
    |> assign(:current_email, user.email)
    |> assign(:current_username, user.username)
    |> assign(:email_form, to_form(email_changeset))
    |> assign(:password_form, to_form(password_changeset))
    |> assign(:username_form, to_form(username_changeset))
    |> assign(:bio_form, to_form(bio_changeset))
    |> assign(:trigger_submit, false)
    |> assign(:current_user, user)
  end
end
