defmodule Arbor.Adapters.PostgresTest do
  use Arbor.TestCase, async: true
  alias Arbor.Adapters.Postgres, as: PGAdapter

  describe "roots/2" do
    test "given an integer primary key, returns a root node query" do
      [dog_root, _branch1, _leaf1, _leaf2, _branch2, _leaf3] = create_conversation("dogs")
      [cat_root, _branch1, _leaf1, _leaf2, _branch2, _leaf3] = create_conversation("cats")

      query = PGAdapter.roots(Comment)
      roots = Repo.all(query)

      assert roots == [dog_root, cat_root]
    end
  end
end
