defmodule BlogWeb.BlogPagesLive.PostLive do
  use BlogWeb, :live_view


  alias Blog.Posts
  alias Blog.Posts.Post
  alias Blog.Repo

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl p-6 bg-gray-100 rounded shadow-md">
      <.header class="text-center text-2xl font-bold mb-6">
        POST PAGE
      </.header>

    </div>
    """
  end

  def mount(params, _session, socket) do
    IO.inspect(params)

    {:ok, socket}
  end


  # def handle_event("create_post", %{"post" => post_params}, socket) do
  #   case Posts.create_post(post_params) do
  #     {:ok, _post} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Post created successfully.")
  #        |> redirect(to: ~p"/blog")}

  #     {:error, changeset} ->
  #       {:noreply, assign_form(socket, changeset)}
  #   end
  # end


  # def handle_event("like_post", %{"id" => post_id}, socket) do
  #   post = Posts.get_post!(post_id) |> IO.inspect()

  #   Posts.increment_post_likes(post) |> IO.inspect()

  #   posts = Posts.list_posts()

  #   {:noreply, assign(socket, posts: posts)}
  # end

  # def handle_event("new_post", _params, socket) do
  #   {:noreply, assign(socket, live_action: :new_post)}
  # end

  # def handle_info(%{topic: "posts", event: "new-post", payload: post}, socket) do
  #     post = Repo.preload(post, :user)

  #     IO.inspect(socket.assigns.current_user)

  #     {:noreply, assign(socket, posts: [post | socket.assigns.posts])}
  # end


  # defp assign_form(socket, %Ecto.Changeset{} = changeset) do
  #   form = to_form(changeset, as: "post")

  #   if changeset.valid? do
  #     assign(socket, form: form, check_errors: false)
  #   else
  #     assign(socket, form: form)
  #   end
  # end

end
