defmodule BlogWeb.BlogLive.Show do
  use BlogWeb, :live_view

  alias Blog.Posts
  alias Blog.Comments

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Comments.subscribe(id)
    end

    post = Posts.get_post!(id)
    comments = Comments.list_comments(id)

    {:ok,
     socket
     |> assign(:post, post)
     |> assign(:comments, comments)
     |> assign(:comment_form, to_form(%{"body" => ""}))}
  end

  @impl true
  def handle_event("save-comment", %{"body" => body}, socket) do
    case Comments.create_comment(%{
           body: body,
           user_id: socket.assigns.current_user.id,
           post_id: socket.assigns.post.id
         }) do
      {:ok, _comment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Comment added successfully")
         |> assign(:comment_form, to_form(%{"body" => ""}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, comment_form: to_form(changeset))}
    end
  end

  @impl true
  def handle_info({:comment_created, comment}, socket) do
    {:noreply, update(socket, :comments, &[comment | &1])}
  end

  def handle_info({:comment_updated, comment}, socket) do
    {:noreply, update(socket, :comments, &update_comment(&1, comment))}
  end

  defp update_comment(comments, updated_comment) do
    Enum.map(comments, fn comment ->
      if comment.id == updated_comment.id, do: updated_comment, else: comment
    end)
  end
end
