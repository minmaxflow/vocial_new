defmodule VocialWeb.PollControllerTest do
  use VocialWeb.ConnCase

  alias Vocial.Votes

  setup do
    conn = build_conn()

    {:ok, user} =
      Vocial.Accounts.create_user(%{
        username: "test",
        email: "test@test.com",
        password: "test",
        password_confirmation: "test"
      })

    {:ok, poll} =
      Vocial.Votes.create_poll_with_options(
        %{"title" => "My New Test Poll", "user_id" => user.id},
        ["a", "b", "c"]
      )

    {:ok, conn: conn, user: user, poll: poll}
  end

  test "GET /polls", %{conn: conn, user: user} do
    {:ok, poll} =
      Votes.create_poll_with_options(%{title: "poll title", user_id: user.id}, ["a", "b", "c"])

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

  test "GET /polls/new without logged in ", %{conn: conn} do
    conn = get(conn, "/polls/new")
    assert redirected_to(conn) == "/"
  end

  test "POST /polls valid data, not logged in", %{conn: conn} do
    conn = post(conn, "/polls", %{"poll" => %{"title" => "poll title"}, "options" => "a,b,c"})
    assert redirected_to(conn) == "/"
  end

  test "POST /polls valid", %{conn: conn, user: user} do
    conn =
      conn
      |> login(user)
      |> post("/polls", %{"poll" => %{"title" => "poll title"}, "options" => "a,b,c"})

    assert redirected_to(conn) == "/polls"
  end

  test "POST /polls invalid", %{conn: conn, user: user} do
    conn =
      conn
      |> login(user)
      |> post("/polls", %{"poll" => %{}, "options" => "a,b,c"})

    assert redirected_to(conn) == "/polls/new"
  end

  test "GET /options/:id/vote", %{conn: conn, poll: poll} do
    option = Enum.at(poll.options, 0)
    before_votes = option.votes
    conn = get(conn, "/options/#{option.id}/vote")
    after_option = Vocial.Repo.get!(Votes.Option, option.id)

    assert html_response(conn, 302)
    assert redirected_to(conn) == "/polls"
    assert after_option.votes == before_votes + 1
  end

  test "GET /polls/:id", %{conn: conn, poll: poll} do
    conn = get(conn, "/polls/#{poll.id}")
    assert html_response(conn, 200) =~ poll.title
  end

  defp login(conn, user) do
    conn
    |> post("/sessions", %{username: user.username, password: user.password})
  end
end
