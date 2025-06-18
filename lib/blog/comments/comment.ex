defmodule Blog.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @status_values [:active, :banned]

  schema "comments" do
    field :likes_count, :integer, default: 0
    field :status, Ecto.Enum, values: @status_values
    field :body, :string
    belongs_to :user, Blog.Accounts.User
    belongs_to :post, Blog.Posts.Post

    timestamps(type: :utc_datetime)
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:likes_count, :status, :body, :user_id, :post_id])
    |> validate_required([:status, :body, :user_id, :post_id])
    |> validate_inclusion(:status, @status_values)
  end
end
