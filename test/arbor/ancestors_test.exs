defmodule Arbor.AncestorsTest do
  use Arbor.TestCase

  describe "ancestors/1 with an integer PK" do
    test "given a struct w/ returns its ancestors" do
      [root, branch1, _, leaf2, _, _] = create_chatter("pupperinos")

      ancestors =
        leaf2
        |> Comment.ancestors()
        |> Repo.all()

      assert ancestors == [root, branch1]
    end
  end

  describe "ancestors/1 with a UUID PK" do
    test "given a struct w/ returns its ancestors" do
      root = create_folder("chauncy")
      docs = create_folder("Documents", parent: root)
      downloads = create_folder("Downloads", parent: root)

      create_folder("resumes", parent: docs)
      create_folder("taxes", parent: docs)
      movies = create_folder("movies", parent: downloads)
      lotr = create_folder("lotr", parent: movies)

      ancestors =
        lotr
        |> Folder.ancestors()
        |> Folder.by_inserted_at()
        |> Repo.all()
        |> Enum.map(& &1.name)

      assert ancestors == ["chauncy", "Downloads", "movies"]
    end
  end

  describe "ancestors/1 with a UUID PK and other than id column name" do
    test "given a struct w/ returns its ancestors" do
      root = create_foreign("chauncy")
      docs = create_foreign("Documents", parent: root)
      downloads = create_foreign("Downloads", parent: root)

      create_foreign("resumes", parent: docs)
      create_foreign("taxes", parent: docs)
      movies = create_foreign("movies", parent: downloads)
      lotr = create_foreign("lotr", parent: movies)

      ancestors =
        lotr
        |> Foreign.ancestors()
        |> Foreign.by_inserted_at()
        |> Repo.all()
        |> Enum.map(& &1.name)

      assert ancestors == ["chauncy", "Downloads", "movies"]
    end
  end

  describe "ancestors/1 in another schema" do
    test "given a struct w/ a prefix returns its ancestors" do
      [_, _, _, leaf2, _, _] = create_chatter("pupperinos")

      ancestors =
        leaf2.__meta__.prefix
        |> put_in("private")
        |> Comment.ancestors()
        |> Repo.all()

      assert ancestors == []
    end
  end
end
