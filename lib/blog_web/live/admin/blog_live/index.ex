defmodule BlogWeb.Admin.BlogLive.Index do
  use BlogWeb, :live_view

  alias Blog.Posts

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns.current_user && socket.assigns.current_user.is_admin do
      if connected?(socket), do: Posts.subscribe()
      {:ok, assign(socket, :posts, list_posts())}
    else
      {:ok,
        socket
        |> put_flash(:error, "You must be an administrator to access this page")
        |> redirect(to: ~p"/blog")}
    end
  end

  @impl true
  def handle_event("change-status", %{"id" => id, "status" => status}, socket) do
    post = Posts.get_post!(id)
    {:ok, _post} = Posts.update_post_status(post, String.to_existing_atom(status))
    {:noreply, socket}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, update(socket, :posts, &update_post_in_list(&1, post))}
  end

  defp list_posts, do: Posts.list_all_posts()

  defp update_post_in_list(posts, updated_post) do
    Enum.map(posts, fn post ->
      if post.id == updated_post.id, do: updated_post, else: post
    end)
  end

  defp status_badge_class(status) do
    base_classes = "px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
    case status do
      :active -> "#{base_classes} bg-green-100 text-green-800"
      :banned -> "#{base_classes} bg-red-100 text-red-800"
    end
  end
end
