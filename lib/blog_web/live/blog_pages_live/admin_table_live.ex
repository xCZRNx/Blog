defmodule BlogWeb.BlogPagesLive.AdminTableLive do
  use BlogWeb, :live_view

  alias Blog.Posts
  alias Blog.Posts.Post
  alias Blog.Repo

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl p-6 bg-gray-100 rounded shadow-md">
      <.header class="text-center text-2xl font-bold mb-6">
        ADMIN PAGE
      </.header>
      <%= if @posts == [] do %>
        <p class="text-center text-gray-500">No posts available.</p>
      <% else %>
        <p class="text-lg font-semibold mb-4">Posts available:</p>

        <%= for post <- @posts do %>
          <.link href={"/blog/post/#{post.id}"}>View details</.link>
          <div class="border p-4 mb-4 rounded bg-white shadow-sm">
            <h2 class="text-lg font-bold text-gray-800">{post.user.email}</h2>
            <p class="text-gray-700">{post.body}</p>
            <div class="likes mt-4 flex items-center justify-between">
              <p class="text-sm text-gray-600">Likes: {post.likes_count}</p>
            </div>
            <div class="flex justify-between mt-4">
              <.button
                phx-click="change_status"
                phx-value-id={post.id}
                class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600"
              >
                Change Status
              </.button>
              <p class="text-sm text-gray-600">Status: {post.status}</p>
            </div>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    IO.inspect(socket.assigns.current_user.is_admin)

    if !socket.assigns.current_user.is_admin do
      {:ok,
       socket
       |> put_flash(:error, "You are not authorized to access this page.")
       |> redirect(to: ~p"/blog")}
    else
      posts = Posts.list_posts()

      changeset = Post.changeset(%{})

      socket =
        socket
        |> assign(posts: posts)
        |> assign(live_action: nil)
        |> assign_form(changeset)

      {:ok, socket}
    end
  end

  def handle_event("change_status", %{"id" => post_id}, socket) do
    IO.inspect(post_id)
    post = Posts.get_post!(post_id)
    new_status = if post.status == :active, do: :banned, else: :active

    case Posts.update_post(post, %{status: new_status}) do
      {:ok, _post} ->
        posts = Posts.list_posts()

        socket =
          socket
          |> assign(posts: posts)
          |> put_flash(:info, "Post status updated successfully.")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "post")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
