defmodule MabelsBookshelf.Aggregates.Bookshelf do
  alias MabelsBookshelf.Behaviors.EventSourced
  alias MabelsBookshelf.Behaviors.Event

  defstruct [id: nil, name: nil, owner_id: nil, books: [], events: [], deleted: false, version: -1]


end
