defmodule BlogWeb.BlogPagesLive.PostLive do
  use BlogWeb, :live_view

  alias Blog.Posts
  alias Blog.Posts.Post
  alias Blog.Posts.Comment
  alias Blog.Repo

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl p-6 bg-gray-100 rounded shadow-md">
      <.link patch={~p"/blog"} class="text-blue-500 hover:underline">
        Back to Blog
      </.link>

      <.header class="text-center text-2xl font-bold mb-6">
        POST PAGE
      </.header>
      <div>
        <h1 class="text-3xl font-bold mb-4">{@post.user.email}</h1>

        <p class="text-gray-700 mb-4">{@post.body}</p>
        <p class="text-gray-700 mb-4">Likes: {@post.likes_count}</p>
      </div>
    </div>
    <div>
      <%= for comment <- @post.comments do %>
        <div class="border p-4 mb-4 rounded bg-white shadow-sm">
          <h2 class="text-lg font-bold text-gray-800">{comment.user.email}</h2>
          <p class="text-gray-700">{comment.body}</p>
          <p class="text-gray-700">Likes: {comment.likes_count}</p>
        </div>
      <% end %>
    </div>

    <div class="w-full h-full">
      <h2 class="text-xl font-bold mb-4">Add comment</h2>
      <.simple_form for={@form} id="new_post_form" phx-submit="create_comment" class="space-y-4">
        <.input
          field={@form[:body]}
          type="text"
          label="Comment"
          required
          class="w-full px-3 py-2 border rounded"
        />
        <:actions>
          <.button
            phx-disable-with="Creating post..."
            class="w-full bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
          >
            Create Comment
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(params, _session, socket) do
    post = Posts.get_post!(params["id"]) |> Repo.preload([:user, comments: :user])
    changeset = Comment.changeset(%{})
    IO.inspect(post.status)

    if connected?(socket) do
      BlogWeb.Endpoint.subscribe("comment")
    end

    if post.status == :banned do
      {:ok,
       socket
       |> put_flash(:error, "This post is banned.")
       |> redirect(to: ~p"/blog")}
    else
      socket =
        socket
        |> assign(:post, post)
        |> assign_form(changeset)

      {:ok, socket}
    end
  end

  def handle_event("create_comment", %{"comment" => comment_params}, socket) do
    comment_params =
      comment_params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("post_id", socket.assigns.post.id)
      |> Map.put("status", "active")

    case Posts.create_comment(comment_params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> assign_form(Comment.changeset(%{}))
         |> put_flash(:info, "Comment created successfully.")
         |> redirect(to: ~p"/blog/post/#{socket.assigns.post.id}")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_info(%{topic: "comment", event: "new-comment", payload: _comment}, socket) do
    post = Posts.get_post!(socket.assigns.post.id) |> Repo.preload([:user, comments: :user])

    {:noreply, assign(socket, post: post)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "comment")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
