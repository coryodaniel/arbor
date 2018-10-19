defmodule Arbor.RootsTest do
  use Arbor.TestCase

  describe "roots/0 with an integer PK" do
    test "returns root nodes" do
      [dog_root | _] = create_chatter("pupperinos")
      [cat_root | _] = create_chatter("kittehs")

      roots = Comment.roots |> Repo.all

      assert length(roots) == 2
      assert Enum.member?(roots, dog_root)
      assert Enum.member?(roots, cat_root)
    end
  end

  describe "roots/0 with a UUID PK" do
    test "returns root nodes" do
      chauncy = create_folder("chauncy")
      create_folder("Documents", parent: chauncy)
      create_folder("Downloads", parent: chauncy)

      raul = create_folder("raul")
      create_folder("Documents", parent: raul)
      create_folder("Downloads", parent: raul)

      roots = Folder.roots |> Repo.all

      assert length(roots) == 2
      assert Enum.member?(roots, chauncy)
      assert Enum.member?(roots, raul)
    end
  end

  describe "roots/0 with a UUID PK and other than id column name" do
    test "returns root nodes" do
      chauncy = create_foreign("chauncy")
      create_foreign("Documents", parent: chauncy)
      create_foreign("Downloads", parent: chauncy)

      raul = create_foreign("raul")
      create_foreign("Documents", parent: raul)
      create_foreign("Downloads", parent: raul)

      roots = Foreign.roots |> Repo.all

      assert length(roots) == 2
      assert Enum.member?(roots, chauncy)
      assert Enum.member?(roots, raul)
    end
  end
end
