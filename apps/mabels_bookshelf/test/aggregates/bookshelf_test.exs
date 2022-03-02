defmodule BookshelfTests do
  use ExUnit.Case
  alias MabelsBookshelf.Aggregates.Bookshelf
  alias MabelsBookshelf.Behaviors.Event

  describe "Bookshelf creation" do
    setup do
      [
        bookshelf: Bookshelf.new("0", "1", "test")
      ]
    end

    test "Given new bookshelf, when bookshelf created, bookshelf contains passed in information and defaults",
         context do
      bookshelf = context.bookshelf
      assert bookshelf.id == "0"
      assert bookshelf.name == "test"
      assert bookshelf.owner_id == "1"
      assert bookshelf.deleted == false
      assert bookshelf.books == []
    end

    test "Given no bookshelf, when bookshelf created, bookshelf has pending create event",
         context do
      bookshelf = context.bookshelf

      assert %Event{type: "BookshelfCreated"} =
               List.first(Bookshelf.get_pending_events(bookshelf))
    end
  end

  describe "Book added" do
    setup do
      with bookshelf <- Bookshelf.new("0", "1", "test"),
           bookshelf <- Bookshelf.clear_pending_events(bookshelf),
           {:ok, bookshelf} <- Bookshelf.add_book(bookshelf, "lotr") do
        [
          bookshelf: bookshelf
        ]
      else
        err -> []
      end
    end

    test "Given existing bookshelf, when book added to bookshelf, bookshelf contains book",
         context do
      bookshelf = context.bookshelf

      assert bookshelf.books == ["lotr"]
    end

    test "Given existing bookshelf, when book added to twice bookshelf, returns error", context do
      bookshelf = context.bookshelf

      assert {:error, _} = Bookshelf.add_book(bookshelf, "lotr")
    end

    test "Given existing bookshelf, when book added to bookshelf, bookshelf contains pending book added event",
         context do
      bookshelf = context.bookshelf

      assert %Event{type: "BookAddedToBookshelf"} =
               List.first(Bookshelf.get_pending_events(bookshelf))
    end
  end

  describe "Book removed" do
    setup do
      bookshelf =
        with bookshelf <- Bookshelf.new("0", "1", "test"),
             bookshelf <- Bookshelf.clear_pending_events(bookshelf),
             {:ok, bookshelf} <- Bookshelf.add_book(bookshelf, "lotr"),
             bookshelf <- Bookshelf.clear_pending_events(bookshelf),
             {:ok, bookshelf} <- Bookshelf.remove_book(bookshelf, "lotr") do
          [
            bookshelf: bookshelf
          ]
        else
          err -> []
        end
    end

    test "Given existing bookshelf containing book, when book removed from bookshelf, bookshelf doesn't contain book",
         context do
      bookshelf = context.bookshelf

      assert bookshelf.books == []
    end

    test "Given existing bookshelf, when book removed twice from bookshelf, returns error",
         context do
      bookshelf = context.bookshelf

      assert {:error, _} = Bookshelf.remove_book(bookshelf, "lotr")
    end

    test "Given existing bookshelf containing book, when book removed from bookshelf, bookshelf contains pending book removed event",
         context do
      bookshelf = context.bookshelf

      assert %Event{type: "BookRemovedFromBookshelf"} =
               List.first(Bookshelf.get_pending_events(bookshelf))
    end
  end

  describe "Bookshelf renamed" do
    setup do
      {:ok, bookshelf} =
        Bookshelf.new("0", "1", "test")
        |> Bookshelf.clear_pending_events()
        |> Bookshelf.rename("name2")

      [
        bookshelf: bookshelf
      ]
    end

    test "Given existing bookshelf named test, when renamed to name2, name is name2", context do
      bookshelf = context.bookshelf

      assert bookshelf.name == "name2"
    end

    test "Given existing bookshelf named test, when renamed to name2 twice, returns error",
         context do
      bookshelf = context.bookshelf

      assert {:error, _} = Bookshelf.rename(bookshelf, "name2")
    end

    test "Given existing bookshelf containing book, when book removed from bookshelf, bookshelf contains pending book removed event",
         context do
      bookshelf = context.bookshelf

      assert %Event{type: "BookshelfRenamed"} =
               List.first(Bookshelf.get_pending_events(bookshelf))
    end
  end

  describe "Bookshelf deleted" do
    setup do
      {:ok, bookshelf} =
        Bookshelf.new("0", "1", "test")
        |> Bookshelf.clear_pending_events()
        |> Bookshelf.delete()

      [
        bookshelf: bookshelf
      ]
    end

    test "Given existing bookshelf, when deleted, bookshelf marked as deleted", context do
      bookshelf = context.bookshelf

      assert bookshelf.deleted == true
    end

    test "Given existing bookshelf, when deleted twice, return error", context do
      bookshelf = context.bookshelf

      assert {:error, _} = Bookshelf.delete(bookshelf)
    end

    test "Given existing bookshelf, when deleted, bookshelf contains pending book delete event",
         context do
      bookshelf = context.bookshelf

      assert %Event{type: "BookshelfDeleted"} =
               List.first(Bookshelf.get_pending_events(bookshelf))
    end
  end
end
