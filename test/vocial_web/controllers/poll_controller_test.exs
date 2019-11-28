defmodule VocialWeb.PollControllerTest do
  use VocialWeb.ConnCase

  test "GET /polls", %{conn: conn} do
    conn = get(conn, "/polls")
    assert html_response(conn, 200) =~ "My First Poll"
  end
end
