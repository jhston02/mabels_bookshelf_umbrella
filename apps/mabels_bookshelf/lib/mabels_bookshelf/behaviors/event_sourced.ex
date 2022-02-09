defmodule MabelsBookshelf.Behaviors.EventSourced do
  alias MabelsBookshelf.Behaviors.Event

  @doc """
  Add event to aggregate
  """
  @callback add_event(term, %Event{}) :: term

  @doc """
  Get pendings events from aggregate
  """
  @callback get_pending_events(term) :: [%Event{}]

  @doc """
  Clear pending events from aggregate
  """
  @callback clear_pending_events(term) :: term
end
