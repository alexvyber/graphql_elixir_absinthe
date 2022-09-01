defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
  end

  object :menu_item do
  end
end
