defmodule MabelsBookshelf.Aggregates.Book do

  @moduledoc """
  The Book module is responsible for the domain logic around books. Note book in this context is an instance of a 'book'. Think more the actual book sitting on a shelf than
  the nebulous book from a publishers perspective
  """
  alias __MODULE__

  defstruct [id: nil, status: :want, isbn: nil, current_page: 0, total_pages: 0, owner_id: nil, events: [], deleted: false, version: -1]

  use MabelsBookshelf.Aggregates.EventSourced

  @started_event "BookStarted"
  @finished_event "BookFinished"
  @quit_event "BookQuit"
  @wanted_event "BookWanted"
  @read_event "ReadToPage"
  @deleted_event "Deleted"
  @created_event "BookCreated"

  @doc """
  Creates a new book
  """
  def new(id, owner_id, total_pages, isbn) do
    data = %{
      "id" => id,
      "total_pages" => total_pages,
      "owner_id" => owner_id,
      "isbn" => isbn
    }
    event = Event.new(@created_event, data)

    %__MODULE__{}
    |> when_event(event)
  end

  @doc """
  Sets the status of a book to reading
  """
  def start_reading(%Book{:status => :reading}), do: {:error, "Already reading book"}

  def start_reading(%Book{} = book) do
    event = Event.new(@started_event, populate_base_event_data(book, %{}))
    {:ok, when_event(book, event)}
  end

  @doc """
  Sets the status of a book to finished
  """
  def finish_reading(%Book{:status => :finished}), do: {:error, "Already finished book"}
  def finish_reading(%Book{:status => :dnf}), do:   {:error, "Book not finished"}

  def finish_reading(%Book{} = book) do
    event = Event.new(@finished_event, populate_base_event_data(book, %{}))
    {:ok, when_event(book, event)}
  end

  @doc """
  Sets the status of a book to 'Did Not finish' (dnf)
  """
  def quit_reading(%Book{status: :dnf}), do: {:error, "Book already not finished"}

  def quit_reading(%Book{} = book) do
    event = Event.new(@quit_event, populate_base_event_data(book, %{}))
    {:ok, when_event(book, event)}
  end

  @doc """
  Sets the status of a book to wanted.
  """
  def want_to_read(%Book{status: :want}), do: {:error, "Book already wanted"}

  def want_to_read(%Book{} = book) do
    event = Event.new(@wanted_event, populate_base_event_data(book, %{}))
    {:ok, when_event(book, event)}
  end

  @doc """
  Set currents to page to the page_number. If this is equal to total pages the book will be set to finished. If the status is not reading it will be set to reading if not finished
  """
  def read_to_page(%Book{total_pages: total_pages}, page_number) when page_number < 0 or page_number > total_pages do
    {:error, "Please enter valid page number"}
  end

  def read_to_page(%Book{current_page: current_page}, page_number) when current_page == page_number do
    {:error, "Please enter a different page number than where you currently have read to"}
  end

  def read_to_page(%Book{:status => :finished}, _page_number) do
    {:error, "Book is already finished"}
  end

  def read_to_page(%Book{status: :reading} = book, page_number) do
    event = Event.new(@read_event, populate_base_event_data(book, %{"page_number" => page_number}))
    book = when_event(book, event)
    |> finish_if_read_to_end

    {:ok, book}
  end

  def read_to_page(%Book{} = book, page_number) do
    {:ok, book} = start_reading(book)
    read_to_page(book, page_number)
  end

  @doc """
  Sets a book to be soft deleted
  """
  def delete(%Book{deleted: true}), do: {:error, "Already deleted"}

  def delete(%Book{} = book) do
    event = Event.new(@deleted_event, populate_base_event_data(book, %{}))
    {:ok, when_event(book, event)}
  end


  #Override the apply_event_function from the EventSource module
  defp apply_event_impl(book, %Event{:type => @started_event}) do
    update_field(book, :status, :reading)
  end

  defp apply_event_impl(book, %Event{:type => @finished_event}) do
    update_field(book, :status, :finished)
  end

  defp apply_event_impl(book, %Event{:type => @quit_event}) do
    update_field(book, :status, :dnf)
  end

  defp apply_event_impl(book, %Event{:type => @wanted_event}) do
    update_field(book, :status, :want)
  end

  defp apply_event_impl(book, %Event{:type => @deleted_event}) do
    update_field(book, :deleted, true)
  end

  defp apply_event_impl(book, %Event{:type => @read_event, :body => %{"page_number" => page_number}}) do
    update_field(book, :current_page, page_number)
  end

  defp apply_event_impl(book, %Event{:type => @created_event, :body => data}) do
    book
    |> update_field(:id, data["id"])
    |> update_field(:isbn, data["isbn"])
    |> update_field(:owner_id, data["owner_id"])
    |> update_field(:total_pages, data["total_pages"])
  end

  defp finish_if_read_to_end(%Book{current_page: current_page, total_pages: total_pages} = book) when current_page == total_pages do
    {:ok, book} = finish_reading(book)
    book
  end

  defp finish_if_read_to_end(book), do: book

  defp update_field(book, field, value) do
    Map.put(book, field, value)
  end

  defp populate_base_event_data(book, event_data) do
    event_data
    |> Map.put("id", book.id)
    |> Map.put("owner_id", book.owner_id)
  end

  defp when_event(book, event) do
    book
    |> add_event(event)
    |> apply_event(event)
  end
end
