defmodule BlogWeb.Admin.BlogLive do
  def status_badge_class(status) do
    base_classes = "px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
    case status do
      :active -> "#{base_classes} bg-green-100 text-green-800"
      :banned -> "#{base_classes} bg-red-100 text-red-800"
    end
  end
end
