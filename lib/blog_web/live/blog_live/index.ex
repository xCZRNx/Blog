defmodule BlogWeb.BlogLive.Index do
  use BlogWeb, :live_view

  alias Blog.Posts
  alias Blog.Posts.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Posts.subscribe()

    {:ok,
     socket
     |> assign(:posts, list_posts())
     |> assign(:modal_open?, false)
     |> assign(:form, to_form(%{"body" => ""}))}
  end

  @impl true
  def handle_event("open-modal", _, socket) do
    {:noreply, assign(socket, :modal_open?, true)}
  end

  def handle_event("close-modal", _, socket) do
    {:noreply, assign(socket, :modal_open?, false)}
  end

  def handle_event("save", %{"body" => body}, socket) do
    case Posts.create_post(%{
           body: body,
           user_id: socket.assigns.current_user.id
         }) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> assign(modal_open?: false)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("like", %{"id" => id}, socket) do
    post = Posts.get_post!(id)
    {:ok, _updated_post} = Posts.update_post(post, %{likes_count: post.likes_count + 1})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply, update(socket, :posts, &[post | &1])}
  end

  def handle_info({:post_updated, post}, socket) do
    {:noreply, update(socket, :posts, &update_post(&1, post))}
  end

  defp list_posts do
    Posts.list_active_posts()
  end

  defp update_post(posts, updated_post) do
    Enum.map(posts, fn post ->
      if post.id == updated_post.id, do: updated_post, else: post
    end)
  end
end
