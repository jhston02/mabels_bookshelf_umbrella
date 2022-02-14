defmodule MabelsBookshelf.Behaviors.EventSourced do
  alias MabelsBookshelf.Behaviors.Event

  @doc """
  Apply event to aggregate
  """
  @callback apply_event(term, %Event{}) :: term

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

  @doc """
  Get version
  """
  @callback get_version(term) :: number()
end
