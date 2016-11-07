defmodule Arbor.RootsTest do
  use Arbor.TestCase

  describe "roots/0 with an integer PK" do
    test "returns root nodes" do
      [dog_root|_] = create_chatter("pupperinos")
      [cat_root|_] = create_chatter("kittehs")

      roots = Comment.roots
              |> Comment.by_inserted_at
              |> Repo.all

      assert roots == [dog_root, cat_root]
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

      roots = Folder.roots
              |> Folder.by_inserted_at
              |> Repo.all

      assert roots == [chauncy, raul]
    end
  end
end
