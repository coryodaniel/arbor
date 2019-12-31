defmodule Arbor.Adapters.PostgresTest do
  use Arbor.TestCase, async: true
  alias Arbor.Adapters.Postgres, as: PGAdapter

  describe "roots/1" do
    test "given a string schema name, returns a root node query" do
      [_dog_root, _branch1, _leaf1, _leaf2, _branch2, _leaf3] = create_conversation("dogs")
      [_cat_root, _branch1, _leaf1, _leaf2, _branch2, _leaf3] = create_conversation("cats")

      query =
        "comments"
        |> PGAdapter.roots()
        |> select([c], {c.body})

      roots = Repo.all(query)
      sorted_roots = Enum.sort_by(roots, fn {body} -> body end)

      assert sorted_roots == [{"Lets talk about cats"}, {"Lets talk about dogs"}]
    end

    test "given an integer primary key, returns a root node query" do
      [dog_root, _branch1, _leaf1, _leaf2, _branch2, _leaf3] = create_conversation("dogs")
      [cat_root, _branch1, _leaf1, _leaf2, _branch2, _leaf3] = create_conversation("cats")

      query = PGAdapter.roots(Comment)
      roots = Repo.all(query)
      sorted_roots = Enum.sort_by(roots, fn root -> root.id end)

      assert sorted_roots == [dog_root, cat_root]
    end

    test "queries are composable" do
      [dog_root, _branch1, _leaf1, _leaf2, _branch2, _leaf3] = create_conversation("dogs")
      [cat_root, _branch1, _leaf1, _leaf2, _branch2, _leaf3] = create_conversation("cats")

      query = PGAdapter.roots(Comment)
      sorted_roots = query |> Arbor.Comment.by_id() |> Repo.all()

      assert sorted_roots == [dog_root, cat_root]
    end

    test "given an UUID primary key, returns a root node query" do
      chauncys_home = create_folder("chauncy")
      create_folder("Documents", parent: chauncys_home)
      create_folder("Downloads", parent: chauncys_home)

      rauls_home = create_folder("raul")
      create_folder("Documents", parent: rauls_home)
      create_folder("Downloads", parent: rauls_home)

      query = PGAdapter.roots(Folder)
      roots = Repo.all(query)
      sorted_roots = Enum.sort_by(roots, fn root -> root.name end)

      assert sorted_roots == [chauncys_home, rauls_home]
    end
  end

  describe "roots/2" do
    test "given an alternate parent foreign key name, returns a root node query" do
      chauncys_home = create_foreign("chauncy")
      create_foreign("Documents", parent: chauncys_home)
      create_foreign("Downloads", parent: chauncys_home)

      rauls_home = create_foreign("raul")
      create_foreign("Documents", parent: rauls_home)
      create_foreign("Downloads", parent: rauls_home)

      query = PGAdapter.roots(Foreign, foreign_key: :parent_uuid)
      roots = Repo.all(query)
      sorted_roots = Enum.sort_by(roots, fn root -> root.name end)

      assert sorted_roots == [chauncys_home, rauls_home]
    end
  end
end
