defmodule Arbor.ParentTest do
  use Arbor.TestCase

  describe "parent/1 with an integer PK" do
    test "given a struct w/ returns it's children" do
      [_, branch1, leaf1, _, _, _] = create_chatter("pupperinos")

      parent = leaf1
               |> Comment.parent
               |> Repo.one

      assert parent == branch1
    end
  end

  describe "parent/1 with a UUID PK" do
    test "given a struct w/ returns it's children" do
      root = create_folder("chauncy")
      docs = create_folder("Documents", parent: root)
      downloads = create_folder("Downloads", parent: root)

      create_folder("resumes", parent: docs)
      create_folder("taxes", parent: docs)
      create_folder("movies", parent: downloads)

      parent = downloads
               |> Folder.parent
               |> Repo.one

      assert parent == root
    end
  end
end
