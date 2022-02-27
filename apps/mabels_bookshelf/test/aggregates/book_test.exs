defmodule BookTests do
  use ExUnit.Case
  alias MabelsBookshelf.Aggregates.Book
  alias MabelsBookshelf.Aggregates.Book.VolumeInfo
  alias MabelsBookshelf.Behaviors.Event

  describe "Book creation" do
    setup do
      [
        book: Book.new("id", "owner_id", 10, "test")
      ]
    end

    test "Given no book, when book created, book has passed in information", context do
      book = context.book
      assert book.id == "id"
      assert book.status == :want
      assert book.deleted == false
      assert Book.get_version(book) == 0
    end

    test "Given no book, when book created, book has pending create event", context do
      book = context.book
      assert %Event{type: "BookCreated"} = List.first(Book.get_pending_events(book))
    end
  end

  describe "Existing book" do
    setup do
      book = Book.new("id", "owner_id", 20, "test")
      book = Book.clear_pending_events(book)

      [
        book: book
      ]
    end

    test "Given existing book, when start reading book, book status is reading", context do
      book = context.book
      {:ok, book} = Book.start_reading(book)

      assert book.status == :reading
    end

    test "Given existing book, when start reading book and already reading, return error",
         context do
      book = context.book
      {:ok, book} = Book.start_reading(book)

      assert {:error, _message} = Book.start_reading(book)
    end

    test "Given existing book, when finished book, book status is finished", context do
      book = context.book
      {:ok, book} = Book.finish_reading(book)

      assert book.status == :finished
    end

    test "Given existing book, when finished book and already finished, returns error", context do
      book = context.book
      {:ok, book} = Book.finish_reading(book)

      assert {:error, _message} = Book.finish_reading(book)
    end

    test "Given existing book, when finished book and book in dnf status, returns error",
         context do
      book = context.book
      {:ok, book} = Book.quit_reading(book)

      assert {:error, _message} = Book.finish_reading(book)
    end

    test "Given existing book, when quit book, book status is did not finish", context do
      book = context.book
      {:ok, book} = Book.quit_reading(book)

      assert book.status == :dnf
    end

    test "Given existing book, when want book, book status is wanted", context do
      book = context.book
      {:ok, book} = Book.finish_reading(book)
      {:ok, book} = Book.want_to_read(book)

      assert book.status == :want
    end

    test "Given existing book, when deleted book, book deleted is true", context do
      book = context.book
      {:ok, book} = Book.delete(book)

      assert book.deleted == true
    end

    test "Given existing book, when read to page and not currently reading, book status is reading and current page is set to read to",
         context do
      book = context.book
      {:ok, book} = Book.read_to_page(book, 10)
      assert book.status == :reading
      assert book.current_page == 10
    end

    test "Given existing book, when read to page and page is negative, return error", context do
      book = context.book
      assert {:error, _message} = Book.read_to_page(book, -500)
    end

    test "Given existing book, when read to page and page past of end of book, return error",
         context do
      book = context.book
      assert {:error, _message} = Book.read_to_page(book, 500)
    end

    test "Given existing book, when read to page and currently reading, current page is set to read to",
         context do
      book = context.book
      {:ok, book} = Book.start_reading(book)
      {:ok, book} = Book.read_to_page(book, 10)
      assert book.current_page == 10
    end

    test "Given existing book, when read to page and page is end of book, book status is set to finished",
         context do
      book = context.book
      {:ok, book} = Book.read_to_page(book, 20)
      assert book.status == :finished
      assert book.current_page == 20
    end
  end
end
