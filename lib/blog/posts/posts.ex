defmodule Blog.Posts do
  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Posts.Post
  alias Blog.Comments.Comment

  @topic_posts "posts"
  @topic_comments "comments"

  # POSTS

  def list_posts do
    Repo.all(Post)
  end

  def list_active_posts do
    Repo.all(from p in Post, where: p.status == :active)
  end

  def get_post!(id), do: Repo.get!(Post, id)

  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, post} = result ->
        broadcast_post(:created, post)
        result
      error -> error
    end
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  def filter_posts_by_status(status) when status in [:active, :banned] do
    Repo.all(from p in Post, where: p.status == ^status)
  end

  # COMMENTS

  def list_comments do
    Repo.all(Comment)
  end

  def list_comments_for_post(post_id) do
    Repo.all(from c in Comment, where: c.post_id == ^post_id)
  end

  def filter_comments_by_status(status) when status in [:active, :banned] do
    Repo.all(from c in Comment, where: c.status == ^status)
  end

  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, comment} = result ->
        broadcast_comment(:created, comment)
        result
      error -> error
    end
  end

  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  # BROADCASTING

  def subscribe_posts do
    Phoenix.PubSub.subscribe(Blog.PubSub, @topic_posts)
  end

  def subscribe_comments do
    Phoenix.PubSub.subscribe(Blog.PubSub, @topic_comments)
  end

  defp broadcast_post(event, post) do
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic_posts, {event, post})
  end

  defp broadcast_comment(event, comment) do
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic_comments, {event, comment})
  end
end
