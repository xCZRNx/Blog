defmodule Blog.Comments do
  import Ecto.Query
  alias Blog.Repo
  alias Blog.Comments.Comment

  @topic "comments"

  def subscribe(post_id) do
    Phoenix.PubSub.subscribe(Blog.PubSub, "#{@topic}:#{post_id}")
  end

  def list_comments(post_id) do
    Repo.all(
      from c in Comment,
        where: c.post_id == ^post_id,
        order_by: [desc: c.inserted_at],
        preload: [:user]
    )
  end

  def list_comments_by_status(post_id, status) do
    Repo.all(
      from c in Comment,
        where: c.post_id == ^post_id and c.status == ^status,
        order_by: [asc: c.inserted_at]
    )
  end

  def get_comment!(id), do: Repo.get!(Comment, id)

  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:comment_created)
  end

  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
    |> broadcast(:comment_updated)
  end

  def delete_comment(%Comment{} = comment) do
    comment
    |> Repo.delete()
    |> broadcast(:comment_deleted)
  end

  defp broadcast({:ok, comment} = result, event) do
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      "#{@topic}:#{comment.post_id}",
      {event, comment}
    )
    result
  end

  defp broadcast({:error, _} = result, _event), do: result
end
