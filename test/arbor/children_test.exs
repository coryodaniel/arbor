defmodule Arbor.ChildrenTest do
  use Arbor.TestCase

  describe "children/1 with an integer PK" do
    test "given a struct w/ returns it's children" do
      [_root, branch1, leaf1, leaf2, _, _] = create_chatter("pupperinos")

      children = branch1
                 |> Comment.children
                 |> Comment.by_inserted_at
                 |> Repo.all

      assert children == [leaf1, leaf2]
    end
  end

  describe "children/1 with a UUID PK" do
    test "given a struct w/ returns it's children" do
      root = create_folder("chauncy")
      docs = create_folder("Documents", parent: root)
      downloads = create_folder("Downloads", parent: root)

      resumes = create_folder("resumes", parent: docs)
      taxes   = create_folder("taxes", parent: docs)
      _movies  = create_folder("movies", parent: downloads)

      folders = docs
                |> Folder.children
                |> Folder.by_inserted_at
                |> Repo.all

      assert folders == [resumes, taxes]
    end
  end
end
