defmodule VocialWeb.VerifyUserSession do
  def init(opts), do: opts

  import Plug.Conn, only: [get_session: 2, halt: 1]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def call(conn, _opt) do
    case get_session(conn, :user) do
      nil ->
        conn
        |> put_flash(:error, "You must be logged in to to that!")
        |> redirect(to: "/")
        |> halt()

      _ ->
        conn
    end
  end
end
