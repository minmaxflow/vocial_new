defmodule Vocial.Votes.Option do
  use Ecto.Schema
  import Ecto.Changeset
  alias Vocial.Votes.{Option, Poll}

  schema "options" do
    field :title, :string
    field :votes, :integer, default: 0
    # defaults to the name of the association suffixed by _id. 
    # For example, belongs_to :company will define foreign key of :company_id. 
    # 可以通过 :foreign_key 来定制
    belongs_to :poll, Poll

    timestamps()
  end

  def changeset(%Option{} = option, attrs) do
    option
    |> cast(attrs, [:title, :votes, :poll_id])
    |> validate_required([:title, :votes, :poll_id])
  end
end
