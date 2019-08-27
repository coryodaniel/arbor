defmodule Arbor.ChildrenTest do
  use Arbor.TestCase

  describe "children/1 with an integer PK" do
    test "given a struct w/ returns it's children" do
      [_root, branch1, leaf1, leaf2, _, _] = create_chatter("pupperinos")

      children =
        branch1
        |> Comment.children()
        |> Repo.all()

      assert length(children) == 2
      assert Enum.member?(children, leaf1)
      assert Enum.member?(children, leaf2)
    end
  end

  describe "children/1 with a UUID PK" do
    test "given a struct w/ returns it's children" do
      root = create_folder("chauncy")
      docs = create_folder("Documents", parent: root)
      downloads = create_folder("Downloads", parent: root)

      resumes = create_folder("resumes", parent: docs)
      taxes = create_folder("taxes", parent: docs)
      _movies = create_folder("movies", parent: downloads)

      folders =
        docs
        |> Folder.children()
        |> Repo.all()

      assert length(folders) == 2
      assert Enum.member?(folders, resumes)
      assert Enum.member?(folders, taxes)
    end
  end

  describe "children/1 with a UUID PK and other than id column name" do
    test "given a struct w/ returns it's children" do
      root = create_foreign("chauncy")
      docs = create_foreign("Documents", parent: root)
      downloads = create_foreign("Downloads", parent: root)

      resumes = create_foreign("resumes", parent: docs)
      taxes = create_foreign("taxes", parent: docs)
      _movies = create_foreign("movies", parent: downloads)

      foreigns =
        docs
        |> Foreign.children()
        |> Foreign.by_inserted_at()
        |> Repo.all()

      assert length(foreigns) == 2
      assert Enum.member?(foreigns, resumes)
      assert Enum.member?(foreigns, taxes)
    end
  end
end
