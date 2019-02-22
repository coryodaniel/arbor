defmodule Arbor.DescendantsTest do
  use Arbor.TestCase

  describe "descendants/1 with an integer PK" do
    test "given a struct w/ returns its descendants" do
      [root | tail] = create_chatter("pupperinos")
      _cat_comments = create_chatter("kittehs")

      dog_thread =
        root
        |> Comment.descendants()
        |> Comment.by_inserted_at()
        |> Repo.all()

      assert dog_thread == tail
    end

    test "given a depth returns its descendants up to that depth" do
      [root | descendants] = create_chatter("pupperinos")
      [branch1, _leaf1, _leaf2, branch2, _leaf3] = descendants
      _cat_comments = create_chatter("kittehs")

      dog_thread =
        root
        |> Comment.descendants(1)
        |> Repo.all()

      assert dog_thread == [branch1, branch2]

      dog_thread =
        root
        |> Comment.descendants(2)
        |> Repo.all()

      assert dog_thread == descendants

      dog_thread =
        root
        |> Comment.descendants(3)
        |> Repo.all()

      assert dog_thread == descendants

      dog_thread =
        root
        |> Comment.descendants(9999)
        |> Repo.all()

      assert dog_thread == descendants
    end
  end

  describe "descendants/1 with a UUID PK" do
    test "given a struct w/ returns its descendants" do
      root = create_folder("chauncy")
      docs = create_folder("Documents", parent: root)
      downloads = create_folder("Downloads", parent: root)

      create_folder("resumes", parent: docs)
      create_folder("taxes", parent: docs)
      create_folder("movies", parent: downloads)

      folders =
        root
        |> Folder.descendants()
        |> Folder.by_inserted_at()
        |> Repo.all()
        |> Enum.map(& &1.name)

      assert folders == ["Documents", "Downloads", "resumes", "taxes", "movies"]
    end
  end

  describe "descendants/1 with a UUID PK and other than id column name" do
    test "given a struct w/ returns its descendants" do
      root = create_foreign("chauncy")
      docs = create_foreign("Documents", parent: root)
      downloads = create_foreign("Downloads", parent: root)

      create_foreign("resumes", parent: docs)
      create_foreign("taxes", parent: docs)
      create_foreign("movies", parent: downloads)

      foreigns =
        root
        |> Foreign.descendants()
        |> Foreign.by_inserted_at()
        |> Repo.all()
        |> Enum.map(& &1.name)

      assert foreigns == ["Documents", "Downloads", "resumes", "taxes", "movies"]
    end
  end

  describe "descendants/1 in another schema" do
    test "given a struct w/ a schema prefix it returns its ancestors" do
      [root | _] = create_chatter("pupperinos")

      descendants =
        root.__meta__.prefix
        |> put_in("private")
        |> Comment.descendants()
        |> Comment.by_inserted_at()
        |> Repo.all()

      assert [] == descendants
    end
  end
end
