defmodule VocialWeb.PollControllerTest do
  use VocialWeb.ConnCase

  alias Vocial.Votes

  test "GET /polls", %{conn: conn} do
    {:ok, poll} = Votes.create_poll_with_options(%{title: "poll title"}, ["a", "b", "c"])
    conn = get(conn, "/polls")

    assert html_response(conn, 200) =~ poll.title

    Enum.each(
      poll.options,
      fn option ->
        assert html_response(conn, 200) =~ option.title
        assert html_response(conn, 200) =~ "#{option.votes}"
      end
    )
  end
end
