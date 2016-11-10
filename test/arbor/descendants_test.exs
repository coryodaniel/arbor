defmodule Arbor.DescendantsTest do
  use Arbor.TestCase

  describe "descendants/1 with an integer PK" do
    test "given a struct w/ returns its descendants" do
      [root | tail] = create_chatter("pupperinos")
      _cat_comments = create_chatter("kittehs")

      dog_thread =
        root
        |> Comment.descendants
        |> Comment.by_inserted_at
        |> Repo.all

      assert dog_thread == tail
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
        |> Folder.descendants
        |> Folder.by_inserted_at
        |> Repo.all
        |> Enum.map(&(&1.name))

      assert folders == ["Documents", "Downloads", "resumes", "taxes", "movies"]
    end
  end
end
