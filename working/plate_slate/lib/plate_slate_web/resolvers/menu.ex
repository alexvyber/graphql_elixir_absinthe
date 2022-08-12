defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.Menu

  def menu_items(_, args, _) do
    case args do
      args when map_size(args) > 0 ->
        {:ok, Menu.list_items(args)}

      %{} ->
        {:ok, Menu.list_items()}
    end
  end
end
