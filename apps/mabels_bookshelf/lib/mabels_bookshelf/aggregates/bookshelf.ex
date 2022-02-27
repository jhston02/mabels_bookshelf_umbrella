defmodule MabelsBookshelf.Aggregates.Bookshelf do
  alias MabelsBookshelf.Aggregates.Bookshelf

  defstruct id: nil, name: nil, owner_id: nil, books: [], deleted: false

  use MabelsBookshelf.Aggregates.EventSourced, module: Bookshelf

  @bookshelf_created_event "BookshelfCreated"
  @book_added_event "BookAddedToBookshelf"
  @book_removed_event "BookRemovedFromBookshelf"
  @bookshelf_deleted "BookshelfDeleted"
  @bookshelf_renamed "BookshelfRenamed"

  @doc """
  Created a new empty bookshelf
  """
  def new(id, owner_id, name) do
    data = %{
      "id" => id,
      "owner_id" => owner_id,
      "name" => name
    }

    event = Event.new(@bookshelf_created_event, data)

    %Bookshelf{}
    |> when_event(event)
  end

  @doc """
  Adds specified book to bookshelf
  """
  def add_book(%Bookshelf{} = bookshelf, book_id) do
    if book_id not in bookshelf.books do
      data = %{
        "book_id" => book_id
      }

      event = Event.new(@book_added_event, populate_base_event_data(bookshelf, data))
      {:ok, when_event(bookshelf, event)}
    else
      {:error, "Book already added to bookshelf"}
    end
  end

  @doc """
  Removes specified book from bookshelf
  """
  def remove_book(%Bookshelf{} = bookshelf, book_id) do
    if book_id in bookshelf.books do
      data = %{
        "book_id" => book_id
      }

      event = Event.new(@book_removed_event, populate_base_event_data(bookshelf, data))
      {:ok, when_event(bookshelf, event)}
    else
      {:error, "Book not in bookshelf"}
    end
  end

  @doc """
  Renames bookshelf
  """
  def rename(%Bookshelf{} = bookshelf, name) when bookshelf.name == name do
    {:error, "Bookshelf already named that"}
  end

  def rename(%Bookshelf{} = bookshelf, name) do
    data = %{
      "name" => name
    }

    event = Event.new(@bookshelf_renamed, populate_base_event_data(bookshelf, data))
    {:ok, when_event(bookshelf, event)}
  end

  @doc """
  Soft deletes bookshelf
  """
  def delete(%Bookshelf{} = bookshelf) do
    event = Event.new(@bookshelf_deleted, populate_base_event_data(bookshelf, %{}))
    {:ok, when_event(bookshelf, event)}
  end

  defp apply_event_impl(bookshelf, %Event{type: @bookshelf_created_event, body: body}) do
    bookshelf
    |> update_field(:id, body["id"])
    |> update_field(:name, body["name"])
    |> update_field(:owner_id, body["owner_id"])
  end

  defp apply_event_impl(bookshelf, %Event{type: @book_added_event, body: body}) do
    updated_books = [body["book_id"] | bookshelf.books]

    update_field(bookshelf, :books, updated_books)
  end

    # Override the apply_event_function from the EventSource module
  defp apply_event_impl(bookshelf, %Event{type: @book_removed_event, body: body}) do
    updated_books = List.delete(bookshelf.books, body["book_id"])

    update_field(bookshelf, :books, updated_books)
  end

  defp apply_event_impl(bookshelf, %Event{type: @bookshelf_renamed, body: body}) do
    update_field(bookshelf, :name, body["name"])
  end

  defp apply_event_impl(bookshelf, %Event{type: @bookshelf_deleted}) do
    update_field(bookshelf, :deleted, true)
  end

  defp update_field(bookshelf, field, value) do
    Map.put(bookshelf, field, value)
  end

  defp populate_base_event_data(bookshelf, event_data) do
    event_data
    |> Map.put("id", bookshelf.id)
    |> Map.put("owner_id", bookshelf.owner_id)
  end
end
