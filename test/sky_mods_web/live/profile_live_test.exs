defmodule SkyModsWeb.ProfileLiveTest do
  use SkyModsWeb.ConnCase

  import Phoenix.LiveViewTest
  import SkyMods.AccountsFixtures

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
    {:ok, _lv, html} = live(conn, ~p"/profiles/#{user.id}")
    assert html =~ user.username
  end
end
