defmodule SkyModsWeb.HomeLiveTest do
  use SkyModsWeb.ConnCase

  import Phoenix.LiveViewTest

  test "should render the home page", %{conn: conn} do
    {:ok, _, html} = live(conn, ~p"/")

    assert html =~ "welcome"
  end
end
