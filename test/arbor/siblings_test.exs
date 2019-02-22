defmodule Arbor.SiblingsTest do
  use Arbor.TestCase

  describe "siblings/1 with an integer PK" do
    test "given a struct w/ returns it's children" do
      [_, _, leaf1, leaf2, _, _] = create_chatter("pupperinos")

      siblings =
        leaf1
        |> Comment.siblings()
        |> Repo.all()

      assert siblings == [leaf2]
    end
  end

  describe "siblings/1 with a UUID PK" do
    test "given a struct w/ returns it's children" do
      root = create_folder("chauncy")
      docs = create_folder("Documents", parent: root)
      downloads = create_folder("Downloads", parent: root)

      resumes = create_folder("resumes", parent: docs)
      taxes2015 = create_folder("taxes-2015", parent: docs)
      taxes2016 = create_folder("taxes-2016", parent: docs)
      _movies = create_folder("movies", parent: downloads)

      siblings =
        resumes
        |> Folder.siblings()
        |> Repo.all()

      assert length(siblings) == 2
      assert Enum.member?(siblings, taxes2015)
      assert Enum.member?(siblings, taxes2016)
    end
  end

  describe "siblings/1 with a UUID PK and other than id column name" do
    test "given a struct w/ returns it's children" do
      root = create_foreign("chauncy")
      docs = create_foreign("Documents", parent: root)
      downloads = create_foreign("Downloads", parent: root)

      resumes = create_foreign("resumes", parent: docs)
      taxes2015 = create_foreign("taxes-2015", parent: docs)
      taxes2016 = create_foreign("taxes-2016", parent: docs)
      _movies = create_foreign("movies", parent: downloads)

      siblings =
        resumes
        |> Foreign.siblings()
        |> Repo.all()

      assert length(siblings) == 2
      assert Enum.member?(siblings, taxes2015)
      assert Enum.member?(siblings, taxes2016)
    end
  end

  describe "siblings/1 in another schema" do
    test "given a struct w/ a prefix returns its ancestors" do
      [_, _, leaf1, _, _, _] = create_chatter("pupperinos")

      siblings =
        leaf1.__meta__.prefix
        |> put_in("private")
        |> Comment.siblings()
        |> Repo.all()

      assert siblings == []
    end
  end
end
