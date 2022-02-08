defmodule MabelsBookshelf.Aggregates.Book do
  defstruct [id: nil, volume_info: %{}, status: :want, current_page: 0, owner_id: nil, events: []]

  alias MabelsBookshelf.Behaviors.EventSourced
  alias MabelsBookshelf.Behaviors.Event


  def apply(%__MODULE__{} = book, %Event{:type => :started}) do
    %{book | status: :reading}
  end

  def apply(%__MODULE__{} = book, %Event{:type => :finished}) do
    %{book | status: :finished}
  end

  def apply(%__MODULE__{} = book, %Event{:type => :quit}) do
    %{book | status: :dnf}
  end

  def apply(%__MODULE__{} = book, %Event{:type => :want}) do
    %{book | status: :want}
  end

  def apply(%__MODULE__{} = book, %Event{:type => :read_to_page, :data => %{page_number: page_number}}) do
    %{book | current_page: page_number}
  end


  @behaviour EventSourced

  @impl EventSourced
  def add_event(book, %MabelsBookshelf.Behaviors.Event{} = event) do
    Map.update(book, :event, [], &([event | &1]))
  end

  @impl EventSourced
  def clear_pending_events(book) do
    %{book | events: []}
  end

  @impl EventSourced
  def get_pending_events(book) do
    book.events
  end
end
