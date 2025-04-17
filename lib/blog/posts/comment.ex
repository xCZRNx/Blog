defmodule Blog.Posts.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :body, :string
    field :status, Ecto.Enum, values: [:active, :banned]
    field :likes_count, :integer, default: 0

    belongs_to :post, Blog.Posts.Post
    belongs_to :user, Blog.Accounts.User

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :status, :post_id, :user_id])
    |> validate_required([:body, :status, :post_id, :user_id])
  end

  def likes_count_changeset(comment, attrs) do
    comment
    |> cast(attrs, [:likes_count])
    |> validate_required([:likes_count])
  end


end
