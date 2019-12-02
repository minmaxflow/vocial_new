defmodule VocialWeb.ChatChannelTest do
  use VocialWeb.ChannelCase

  alias VocialWeb.ChatChannel

  setup do
    {:ok, user} =
      Vocial.Accounts.create_user(%{
        username: "test",
        email: "test@test.com",
        password: "test",
        password_confirmation: "test"
      })

    {:ok, poll} =
      Vocial.Votes.create_poll_with_options(
        %{
          title: "poll title",
          user_id: user.id
        },
        ["a", "b", "c"]
      )

    socket = socket(VocialWeb.UserSocket, "user_id", %{user_id: user.id})
    {:ok, _, poll_socket} = subscribe_and_join(socket, ChatChannel, "chat:#{poll.id}", %{})
    {:ok, _, lobby_socket} = subscribe_and_join(socket, ChatChannel, "chat:lobby", %{})

    {:ok, user: user, poll: poll, poll_socket: poll_socket, lobby_socket: lobby_socket}
  end

  test "new_message for chat:poll_id", %{poll_socket: socket} do
    ref = push(socket, "new_message", %{"author" => "test", "message" => "Hello"})
    assert_reply ref, :ok, %{author: author, message: message}
    assert author == "test"
    assert message == "Hello"

    assert_broadcast "new_message", %{author: author, message: message}
    assert author == "test"
    assert message == "Hello"
  end

  test "new_message for chat:lobby", %{lobby_socket: socket} do
    ref = push(socket, "new_message", %{"author" => "test", "message" => "Hello"})
    assert_reply ref, :ok, %{author: author, message: message}
    assert author == "test"
    assert message == "Hello"

    assert_broadcast "new_message", %{author: author, message: message}
    assert author == "test"
    assert message == "Hello"
  end
end
