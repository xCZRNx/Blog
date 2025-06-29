defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @status_values [:active, :banned]

  schema "posts" do
    field :likes_count, :integer, default: 0
    field :status, Ecto.Enum, values: @status_values
    field :body, :string
    belongs_to :user, Blog.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:likes_count, :status, :body, :user_id])
    |> validate_required([:status, :body, :user_id])
    |> validate_inclusion(:status, @status_values)
  end
end
