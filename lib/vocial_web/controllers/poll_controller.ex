defmodule VocialWeb.PollController do
  use VocialWeb, :controller

  plug VocialWeb.VerifyUserSession when action in [:new, :create]

  alias Vocial.Votes

  def index(conn, _params) do
    polls = Votes.list_polls()

    render(conn, "index.html", polls: polls)
  end

  def new(conn, _params) do
    poll = Votes.new_poll()
    render(conn, "new.html", poll: poll)
  end

  def create(conn, %{"poll" => poll_params, "options" => options, "image_data" => image_data}) do
    split_optiosn = String.split(options, ",")

    with user <- get_session(conn, :user),
         poll_params <- Map.put(poll_params, "user_id", user.id),
         {:ok, _} <- Votes.create_poll_with_options(poll_params, split_optiosn, image_data) do
      conn
      |> put_flash(:info, "Poll created successfully!")
      |> redirect(to: Routes.poll_path(conn, :index))
    else
      {:error, _} ->
        conn
        |> put_flash(:alert, "Error creating poll!")
        |> redirect(to: Routes.poll_path(conn, :new))
    end
  end

  def create(conn, %{"poll" => _poll_params, "options" => _options} = params) do
    create(conn, Map.put(params, "image_data", nil))
  end

  def vote(conn, %{"id" => id}) do
    voter_ip =
      conn.remote_ip
      |> Tuple.to_list()
      |> Enum.join(".")

    with {:ok, option} <- Votes.vote_on_option(id, voter_ip) do
      conn
      |> put_flash(:info, "Placed a vote for #{option.title}!")
      |> redirect(to: Routes.poll_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "Could not place")
        |> redirect(to: Routes.poll_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    with poll <- Votes.get_poll(id) do
      render(conn, "show.html", poll: poll)
    end
  end
end
