defmodule Arbor.AncestorsTest do
  use Arbor.TestCase

  describe "ancestors/1 with an integer PK" do
    test "given a struct w/ returns its ancestors" do
      [root, branch1, _, leaf2, _, _] = create_chatter("pupperinos")

      ancestors = leaf2
                  |> Comment.ancestors
                  |> Comment.by_inserted_at
                  |> Repo.all

      assert ancestors == [root, branch1]
    end
  end

  describe "ancestors/1 with a UUID PK" do
    test "given a struct w/ returns its ancestors" do
      root = create_folder("chauncy")
      docs = create_folder("Documents", parent: root)
      downloads = create_folder("Downloads", parent: root)

      resumes = create_folder("resumes", parent: docs)
      create_folder("taxes", parent: docs)
      create_folder("movies", parent: downloads)

      ancestors = resumes
                  |> Folder.ancestors
                  |> Folder.by_inserted_at
                  |> Repo.all

      assert ancestors == [root, docs]
    end
  end
end
