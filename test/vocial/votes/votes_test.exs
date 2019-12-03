defmodule Vocial.VotesTest do
  use Vocial.DataCase

  alias Vocial.Votes

  setup do
    {:ok, user} =
      Vocial.Accounts.create_user(%{
        username: "test",
        email: "test@test.com",
        password: "test",
        password_confirmation: "test"
      })

    {:ok, user: user}
  end

  describe "polls" do
    @valid_attrs %{title: "Hello"}

    def poll_fixture(attrs \\ %{}) do
      with create_attrs <- Enum.into(attrs, @valid_attrs),
           {:ok, poll} <- Votes.create_poll(create_attrs),
           poll <- Repo.preload(poll, [:options, :image, :vote_records, :messages]) do
        poll
      end
    end

    test "list_polls/0 returns all polls", %{user: user} do
      poll = poll_fixture(%{user_id: user.id})
      assert Votes.list_polls() == [poll]
    end

    test "get_poll/1", %{user: user} do
      poll = poll_fixture(%{user_id: user.id})
      assert Votes.get_poll(poll.id) == poll
    end

    test "new_poll/0 return a new blank changeset" do
      changeset = Votes.new_poll()
      assert changeset.__struct__ == Ecto.Changeset
    end

    test "create_poll/2 returns a new poll", %{user: user} do
      {:ok, poll} = Votes.create_poll(Map.put(@valid_attrs, :user_id, user.id))
      assert Enum.any?(Votes.list_polls(), fn p -> p.id == poll.id end)
    end

    test "create_poll_with_options/2 returns a new poll with options", %{user: user} do
      title = "Poll with Options"
      options = ["a", "b", "c"]

      {:ok, poll} = Votes.create_poll_with_options(%{title: title, user_id: user.id}, options)

      assert poll.title == title
      assert Enum.count(poll.options) == 3
    end

    test "create_poll_with_options/2 with invalid data" do
      {:error, _} = Votes.create_poll_with_options(%{}, [])
      assert !Enum.any?(Votes.list_polls(), fn p -> !p.title end)
    end

    test "list_most_recent_polls/2 returns polls ordered by most recent first", %{user: user} do
      poll = poll_fixture(%{user_id: user.id})
      poll2 = poll_fixture(%{user_id: user.id})
      poll3 = poll_fixture(%{user_id: user.id})
      assert Votes.list_most_recent_polls() == [poll3, poll2, poll]
    end

    test "list_most_recent_poll/2 with page", %{user: user} do
      _poll = poll_fixture(%{user_id: user.id})
      _poll2 = poll_fixture(%{user_id: user.id})
      poll3 = poll_fixture(%{user_id: user.id})
      _poll4 = poll_fixture(%{user_id: user.id})
      assert Votes.list_most_recent_polls(1, 1) == [poll3]
    end

    test "list_most_recent_poll_with_extra/2 with page", %{user: user} do
      _poll = poll_fixture(%{user_id: user.id})
      poll2 = poll_fixture(%{user_id: user.id})
      poll3 = poll_fixture(%{user_id: user.id})
      _poll4 = poll_fixture(%{user_id: user.id})
      assert Votes.list_most_recent_polls_with_extra(1, 1) == [poll3, poll2]
    end
  end

  describe "options" do
    test "create_option/1", %{user: user} do
      with {:ok, poll} = Votes.create_poll(%{title: "Sample Poll", user_id: user.id}),
           {:ok, option} = Votes.create_option(%{title: "Sample Choice", poll_id: poll.id}),
           option <- Repo.preload(option, :poll) do
        assert Votes.list_options() === [option]
      end
    end

    test "vote_on_option/1", %{user: user} do
      with {:ok, poll} = Votes.create_poll(%{title: "Sample Poll", user_id: user.id}),
           {:ok, option} =
             Votes.create_option(%{title: "Sample choice", votes: 0, poll_id: poll.id}) do
        votes_before = option.votes
        {:ok, updated_option} = Votes.vote_on_option(option.id, "127.0.0.1")
        assert votes_before + 1 == updated_option.votes
      end
    end
  end

  describe "messages" do
    setup %{user: user} do
      {:ok, poll} = Votes.create_poll(%{title: "Sample Poll", user_id: user.id})
      poll_messages = ["Hello", "there", "World"]
      lobby_messages = ["Polls", "are", "neat"]

      Enum.each(poll_messages, fn m ->
        Votes.create_message(%{message: m, author: "Someone", poll_id: poll.id})
      end)

      Enum.each(lobby_messages, fn m ->
        Votes.create_message(%{message: m, author: "Someone"})
      end)

      {:ok, poll: poll}
    end

    test "create_message/1" do
      with {:ok, message} <- Votes.create_message(%{message: "Hello", author: "Someone"}) do
        assert Enum.any?(Votes.list_lobby_messages(), fn msg -> msg.id == message.id end)
      end
    end

    test "list_lobby_messages/0" do
      lobby_messages = Votes.list_lobby_messages()
      assert Enum.count(lobby_messages) > 0
      assert Enum.all?(lobby_messages, fn msg -> is_nil(msg.poll_id) end)
    end

    test "list_poll_messages/1", %{poll: poll} do
      poll_messages = Votes.list_poll_messages(poll.id)
      assert Enum.count(poll_messages) > 0
      assert Enum.all?(poll_messages, fn msg -> msg.poll_id == poll.id end)
    end
  end
end
