defmodule MabelsBookshelf.Aggregates.Book do

  @moduledoc """
  The Book module is responsible for the domain logic around books. Note book in this context is an instance of a 'book'. Think more the actual book sitting on a shelf than
  the nebulous book from a publishers perspective
  """

  alias MabelsBookshelf.Behaviors.EventSourced
  alias MabelsBookshelf.Aggregates.Book.VolumeInfo
  alias MabelsBookshelf.Behaviors.Event

  defstruct [id: nil, volume_info: %VolumeInfo{}, status: :want, current_page: 0, owner_id: nil, events: [], deleted: false, version: -1]

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
  def new(id, owner_id, volume_info) do
    data = %{
      "id" => id,
      "title" => volume_info.title,
      "authors" => volume_info.authors,
      "isbn" => volume_info.isbn,
      "external_id" => volume_info.external_id,
      "total_pages" => volume_info.total_pages,
      "categories" => volume_info.categories,
      "owner_id" => owner_id
    }
    event = Event.new(@created_event, data)

    %__MODULE__{}
    |> when_event(event)
  end

  @doc """
  Sets the status of a book to reading
  """
  def start_reading(%__MODULE__{:status => :reading}), do: {:error, "Already reading book"}

  def start_reading(%__MODULE__{} = book) do
    event = Event.new(@started_event, populate_base_event_data(book, %{}))
    {:ok, when_event(book, event)}
  end

  @doc """
  Sets the status of a book to finished
  """
  def finish_reading(%__MODULE__{:status => :finished}), do: {:error, "Already finished book"}
  def finish_reading(%__MODULE__{:status => :dnf}), do:   {:error, "Book not finished"}

  def finish_reading(%__MODULE__{} = book) do
    event = Event.new(@finished_event, populate_base_event_data(book, %{}))
    {:ok, when_event(book, event)}
  end

  @doc """
  Sets the status of a book to 'Did Not finish' (dnf)
  """
  def quit_reading(%__MODULE__{status: :dnf}), do: {:error, "Book already not finished"}

  def quit_reading(%__MODULE__{} = book) do
    event = Event.new(@quit_event, populate_base_event_data(book, %{}))
    {:ok, when_event(book, event)}
  end

  @doc """
  Sets the status of a book to wanted.
  """
  def want_to_read(%__MODULE__{status: :want}), do: {:error, "Book already wanted"}

  def want_to_read(%__MODULE__{} = book) do
    event = Event.new(@wanted_event, populate_base_event_data(book, %{}))
    {:ok, when_event(book, event)}
  end

  @doc """
  Set currents to page to the page_number. If this is equal to total pages the book will be set to finished. If the status is not reading it will be set to reading if not finished
  """
  def read_to_page(%__MODULE__{:volume_info => %{total_pages: total_pages}}, page_number) when page_number < 0 or page_number > total_pages do
    {:error, "Please enter valid page number"}
  end

  def read_to_page(%__MODULE__{:status => :finished}, _page_number) do
    {:error, "Book is already finished"}
  end

  def read_to_page(%__MODULE__{status: :reading} = book, page_number) do
    event = Event.new(@read_event, populate_base_event_data(book, %{"page_number" => page_number}))
    book = when_event(book, event)
    |> finish_if_read_to_end

    {:ok, book}
  end

  def read_to_page(%__MODULE__{} = book, page_number) do
    {:ok, book} = start_reading(book)
    read_to_page(book, page_number)
  end

  @doc """
  Sets a book to be soft deleted
  """
  def delete(%__MODULE__{deleted: true}), do: {:error, "Already deleted"}

  def delete(%__MODULE__{} = book) do
    event = Event.new(@deleted_event, populate_base_event_data(book, %{}))
    {:ok, when_event(book, event)}
  end

  @doc """
  The apply functions applies an event to a book.
  """
  def apply_event(%__MODULE__{} = book, %Event{} = event) do
    apply_event_impl(book, event)
    |> bump_version()
  end

  defp apply_event_impl(%__MODULE__{} = book, %Event{:type => @started_event}) do
    update_field(book, :status, :reading)
  end

  defp apply_event_impl(%__MODULE__{} = book, %Event{:type => @finished_event}) do
    update_field(book, :status, :finished)
  end

  defp apply_event_impl(%__MODULE__{} = book, %Event{:type => @quit_event}) do
    update_field(book, :status, :dnf)
  end

  defp apply_event_impl(%__MODULE__{} = book, %Event{:type => @wanted_event}) do
    update_field(book, :status, :want)
  end

  defp apply_event_impl(%__MODULE__{} = book, %Event{:type => @deleted_event}) do
    update_field(book, :deleted, true)
  end

  defp apply_event_impl(%__MODULE__{} = book, %Event{:type => @read_event, :body => %{"page_number" => page_number}}) do
    update_field(book, :current_page, page_number)
  end

  defp apply_event_impl(%__MODULE__{} = book, %Event{:type => @created_event, :body => data}) do
    volume_info = VolumeInfo.new(
      data["title"],
      data["authors"],
      data["isbn"],
      data["external_id"],
      data["total_pages"],
      data["categories"]
    )

    book
    |> update_field(:id, data["id"])
    |> update_field(:owner_id, data["owner_id"])
    |> update_field(:volume_info, volume_info)
  end

  defp finish_if_read_to_end(%__MODULE__{current_page: current_page, volume_info: %{total_pages: total_pages}} = book) when current_page == total_pages do
    {:ok, book} = finish_reading(book)
    book
  end

  defp finish_if_read_to_end(book), do: book

  defp bump_version(book) do
    Map.update(book, :version, -1, &(&1+1))
  end

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

  @behaviour EventSourced

  @impl EventSourced
  def add_event(book, %Event{} = event) do
    Map.update(book, :events, [], &([event | &1]))
  end

  @impl EventSourced
  def clear_pending_events(book) do
    %{book | events: []}
  end

  @impl EventSourced
  def get_pending_events(book) do
    book.events
    |> Enum.reverse()
  end

  @impl EventSourced
  def get_version(book) do
    book.version
  end
end
