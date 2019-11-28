defmodule VocialWeb.PollController do
  use VocialWeb, :controller

  def index(conn, _params) do
    poll = %{
      title: "My First Poll",
      options: [
        {"choice 1", 0},
        {"choice 2", 5},
        {"choice 3", 2}
      ]
    }

    render(conn, "index.html", poll: poll)
  end
end
