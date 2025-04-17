defmodule BlogWeb.BlogPagesLive.BlogLive do
  use BlogWeb, :live_view


  alias Blog.Posts
  alias Blog.Posts.Post
  alias Blog.Repo

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl p-6 bg-gray-100 rounded shadow-md">
      <.header class="text-center text-2xl font-bold mb-6">
        BLOG PAGE
      </.header>
      <div class="flex justify-end mb-4">
        <.button phx-click="new_post" phx-value-id={"new_post"} id="new_post" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
          New Post
        </.button>
      </div>

      <%= if @posts == [] do %>
        <p class="text-center text-gray-500">No posts available.</p>
      <% else %>
        <p class="text-lg font-semibold mb-4">Posts available:</p>

        <%= for post <- @posts do %>
          <.link href={"/blog/post/#{post.id}"}>View details</.link>
          <div class="border p-4 mb-4 rounded bg-white shadow-sm">
            <h2 class="text-lg font-bold text-gray-800"><%= post.user.email %></h2>
            <p class="text-gray-700"><%= post.body %></p>
            <div class="likes mt-4 flex items-center justify-between">
              <p class="text-sm text-gray-600">Likes: <%= post.likes_count %></p>
              <.button phx-click="like_post" phx-value-id={post.id} class="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600">
                Like
              </.button>
            </div>
          </div>
        <% end %>
      <% end %>

      <%= if @live_action == :new_post do %>
        <.modal id="new_post_modal" show={true} on_cancel={JS.navigate(~p"/blog")} >
          <div class="w-full h-full">
            <.header class="text-xl font-bold mb-4">New Post</.header>
            <.simple_form
              for={@form}
              id="new_post_form"
              phx-submit="create_post"
              class="space-y-4"
            >
              <.input field={@form[:body]} type="text" label="Post Body" required class="w-full px-3 py-2 border rounded" />
              <.input field={@form[:status]} type="hidden" value={:active} required />
              <.input field={@form[:user_id]} type="hidden" value={@current_user.id} required />
              <:actions>
                <.button phx-disable-with="Creating post..." class="w-full bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
                  Create Post
                </.button>
              </:actions>
            </.simple_form>
          </div>
        </.modal>
      <% end %>
    </div>
    """
  end

  def mount(_params, session, socket) do
    if connected?(socket) do
      BlogWeb.Endpoint.subscribe("posts")
    end

    IO.inspect(session)

    posts = Posts.list_posts()

    changeset = Post.changeset(%{})

    socket =
      socket
      |> assign(posts: posts)
      |> assign(live_action: nil)
      |> assign_form(changeset)

    {:ok, socket}
  end


  def handle_event("create_post", %{"post" => post_params}, socket) do
    case Posts.create_post(post_params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully.")
         |> redirect(to: ~p"/blog")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end


  def handle_event("like_post", %{"id" => post_id}, socket) do
    post = Posts.get_post!(post_id) |> IO.inspect()

    Posts.increment_post_likes(post) |> IO.inspect()

    posts = Posts.list_posts()

    {:noreply, assign(socket, posts: posts)}
  end

  def handle_event("new_post", _params, socket) do
    {:noreply, assign(socket, live_action: :new_post)}
  end

  def handle_info(%{topic: "posts", event: "new-post", payload: post}, socket) do
      post = Repo.preload(post, :user)

      IO.inspect(socket.assigns.current_user)

      {:noreply, assign(socket, posts: [post | socket.assigns.posts])}
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
