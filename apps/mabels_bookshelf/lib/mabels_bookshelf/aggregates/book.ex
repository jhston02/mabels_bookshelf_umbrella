defmodule MabelsBookshelf.Aggregates.Book do
  alias MabelsBookshelf.Behaviors.EventSourced
  alias MabelsBookshelf.Aggregates.Book.VolumeInfo
  alias MabelsBookshelf.Behaviors.Event

  defstruct [id: nil, volume_info: %VolumeInfo{}, status: :want, current_page: 0, owner_id: nil, events: [], deleted: false]

  def new(id, owner_id, volume_info) do
    data = %{
      "id" => id,
      "title" => volume_info["title"],
      "authors" => volume_info["authors"],
      "isbn" => volume_info["isbn"],
      "external_id" => volume_info["external_id"],
      "total_pages" => volume_info["total_pages"],
      "categories" => volume_info["categories"],
      "owner_id" => owner_id
    }
    event = Event.new("BookCreated", data)

    %__MODULE__{}
    |> when_event(event)
  end

  def start_reading(%__MODULE__{:status => :reading}) do
    {:error, "Already reading book"}
  end

  def start_reading(%__MODULE__{} = book) do
    event = Event.new("BookStarted", populate_base_event_data(book, %{}))

    {:ok, when_event(book, event)}
  end

  def finished_reading(%__MODULE__{:status => :finished}) do
    {:error, "Already finished book"}
  end


  def apply_event(%__MODULE__{} = book, %Event{:type => "BookStarted"}) do
    update_field(book, :status, :reading)
  end

  def apply_event(%__MODULE__{} = book, %Event{:type => "BookFinished"}) do
    update_field(book, :status, :finished)
  end

  def apply_event(%__MODULE__{} = book, %Event{:type => "BookQuit"}) do
    update_field(book, :status, :dnf)
  end

  def apply_event(%__MODULE__{} = book, %Event{:type => "BookWanted"}) do
    update_field(book, :status, :want)
  end

  def apply_event(%__MODULE__{} = book, %Event{:type => "ReadToPage", :body => %{"page_number" => page_number}}) do
    update_field(book, :current_page, page_number)
  end

  def apply_event(%__MODULE__{} = book, %Event{:type => "BookCreated", :body => data}) do
    volume_info = VolumeInfo.new(
      data["title"],
      data["authors"],
      data["isbn"],
      data["external_id"],
      data["total_pages"],
      data["categories"]
    )

    book
    |> update_field(:id, data.id)
    |> update_field(:owner_id, data.owner_id)
    |> update_field(:volume_info, volume_info)
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
    Map.update(book, :event, [], &([event | &1]))
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
end
