defmodule SkyModsWeb.ProfileLiveTest do
  use SkyModsWeb.ConnCase

  import Phoenix.LiveViewTest
  import SkyMods.AccountsFixtures

  alias SkyMods.Accounts

  setup do
    %{user: user_fixture()}
  end

  test "should render a not found page if the user id is invalid.", %{conn: conn} do
    {:ok, _lv, html} = live(conn, ~p"/profiles/foo")
    assert html =~ "not found"
  end

  test "should render a not found page if the user is valid but was not found.", %{conn: conn} do
    {:ok, _lv, html} = live(conn, ~p"/profiles/150")
    assert html =~ "not found"
  end

  test "should render the username of the user.", %{conn: conn, user: user} do
    {:ok, target} = Accounts.update_user_bio(user, %{"bio" => "foo is great bar is null"})

    {:ok, _lv, html} = live(conn, ~p"/profiles/#{target.id}")
    assert html =~ target.username
    assert html =~ target.bio
  end
end
