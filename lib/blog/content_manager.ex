defmodule Blog.ContentManager do
  import Ecto.Query, warn: false
  alias Blog.Repo
  alias Blog.Posts
  alias Blog.Comments

  # Posts CRUD

  def list_posts do
    Repo.all(Posts)
  end

  def list_active_posts do
    Repo.all(from p in Posts, where: p.status == ^:active)
  end

  def get_post!(id), do: Repo.get!(Posts, id)

  def create_post(attrs \\ %{}) do
    %Posts{}
    |> Posts.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:post_created)
  end

  def update_post(%Posts{} = post, attrs) do
    post
    |> Posts.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Posts{} = post) do
    Repo.delete(post)
  end

  def filter_posts_by_status(status) do
    Repo.all(from p in Posts, where: p.status == ^status)
  end

  # Comments CRUD

  def list_comments_for_post(post_id) do
    Repo.all(from c in Comments, where: c.post_id == ^post_id)
  end

  def filter_comments_by_status(status) do
    Repo.all(from c in Comments, where: c.status == ^status)
  end

  def get_comment!(id), do: Repo.get!(Comments, id)

  def create_comment(attrs \\ %{}) do
    %Comments{}
    |> Comments.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:comment_created)
  end

  def update_comment(%Comments{} = comment, attrs) do
    comment
    |> Comments.changeset(attrs)
    |> Repo.update()
  end

  def delete_comment(%Comments{} = comment) do
    Repo.delete(comment)
  end

  # Broadcasting helper
  defp broadcast({:ok, result}, event) do
    topic = broadcast_topic(event)
    BlogWeb.Endpoint.broadcast!(topic, event, result)
    {:ok, result}
  end

  defp broadcast(error, _event), do: error

  defp broadcast_topic(:post_created), do: "posts"
  defp broadcast_topic(:comment_created), do: "comments"
end
