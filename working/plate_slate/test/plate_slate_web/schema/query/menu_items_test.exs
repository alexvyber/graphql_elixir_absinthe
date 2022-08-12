defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
  {
  menuItems {
    name
    }
  }
  """

  test "menuItems field returns menu items" do
    conn = build_conn()
    conn = get conn, "/api", query: @query

    assert json_response(conn, 200) ==
             %{
               "data" => %{
                 "menuItems" => [
                   %{"name" => "Bánh mì"},
                   %{"name" => "Chocolate Milkshake"},
                   %{"name" => "Croque Monsieur"},
                   %{"name" => "French Fries"},
                   %{"name" => "Lemonade"},
                   %{"name" => "Masala Chai"},
                   %{"name" => "Muffuletta"},
                   %{"name" => "Papadum"},
                   %{"name" => "Pasta Salad"},
                   %{"name" => "Reuben"},
                   %{"name" => "Soft Drink"},
                   %{"name" => "Vada Pav"},
                   %{"name" => "Vanilla Milkshake"},
                   %{"name" => "Water"}
                 ]
               }
             }
  end

  @query """
  query ( $filter: MenuItemFilter!){
    menuItems(filter: $filter) {
      name
    }
  }
  """
  @variables %{filter: %{"name" => "re"}}
  test "menuItems field returns menu items filtered by name" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert json_response(response, 200) ==
             %{"data" => %{"menuItems" => [%{"name" => "French Fries"}, %{"name" => "Reuben"}]}}
  end

  @query """
  query ($filter: MenuItemFilter!){
  menuItems(filter: $filter) {
  name
  }
  }
  """
  @variables %{filter: %{name: 666}}
  test "menuItesm filed return errors when using an invalid value" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{"data" => %{"menuItems" => []}} = json_response(response, 200)

    # assert message == "Argument \"matching\" has invalid value 666."
  end

  @query """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter){
      name
    }
  }
  """

  @variables %{filter: %{"tag" => "Vegan", "category" => "Sides"}}
  test "menuItems field filters by an,e when using a variable" do
    res = get(build_conn(), "/api", query: @query, variables: @variables)

    assert json_response(res, 200) == %{"data" => %{"menuItems" => [%{"name" => "French Fries"}]}}
  end

  @query """
  {
    menuItems(order: DESC) {
      name
    }
  }
  """
  test "menuItens field returns items descending using literals" do
    res = get(build_conn(), "/api", query: @query)

    assert %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Water"} | _
               ]
             }
           } = json_response(res, 200)
  end

  @query """
  query ($order: SortOrder!) {
    menuItems(order: $order) {
      name
    }
  }
  """
  @variables %{"order" => "ASC"}
  test "menuItems field returns items ascending using variables" do
    res = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Bánh mì"} | _
               ]
             }
           } = json_response(res, 200)
  end

  @query """
  {
    menuItems(filter: {category: "Sandwiches", tag: "Vegetarian"}){
      name
    }
  }
  """
  test "menuItems field returns menuItems filtering with a literal" do
    res = get(build_conn(), "/api", query: @query)

    assert %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Vada Pav"}
               ]
             }
           } == json_response(res, 200)
  end

  @query """
  query($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
      addedOn
    }
  }
  """

  @variables %{filter: %{"addedBefore" => "2021-08-08"}}
  test "menuItems filtered by custom scalar" do
    sides = PlateSlate.Repo.get_by!(PlateSlate.Menu.Category, name: "Sides")

    %PlateSlate.Menu.Item{
      name: "Big Tasty",
      added_on: ~D[2021-08-01],
      price: 2.55,
      category: sides
    }
    |> PlateSlate.Repo.insert!()

    res = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{"data" => %{"menuItems" => [%{"name" => "Big Tasty", "addedOn" => "2021-08-01"}]}} ==
             json_response(res, 200)
  end

  @query """
  query ($filter: MenuItemFilter!) {
  menuItems(filter: $filter) {
  name
  }
  }
  """
  @variables %{filter: %{"addedBefore" => "not-a-date"}}
  test "menuItems filtered by custom scalar with error" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "errors" => [
               %{
                 "locations" => [
                   %{"column" => 11, "line" => 2}
                 ],
                 "message" => message
               }
             ]
           } = json_response(response, 200)

    expected = """
    Argument "filter" has invalid value $filter.
    In field "addedBefore": Expected type "Date", found "not-a-date".\
    """

    assert expected == message
  end
end
