defmodule MabelsBookshelf.EventStoreDbClient  do
  use Spear.Client, otp_app: :mabels_bookshelf
  alias MabelsBookshelf.Behaviors.Event

  def insert(module, entity, stream_name) do
    get_events_from_aggregate(module, entity)
    |> events_to_spear_events()
    |> append(stream_name, expect: :empty)

    clear_pending_events(module, entity)
  end

  def update(module, entity, stream_name) do
    events = get_events_from_aggregate(module, entity)
    revision = calculate_revision(module, events, entity)

    events
    |> events_to_spear_events()
    |> append(stream_name, expect: revision)

    clear_pending_events(module, entity)
  end

  def get(module, stream_name) do
    stream!(stream_name)
    |> apply_events(module)
  end

  defp apply_events(events, module) do
    spear_events_to_events(events)
    |> Enum.reduce(struct(module), fn event, entity ->
      apply(module, :apply_event, [entity, event])
    end)
  end

  defp calculate_revision(module, events, entity) do
    version = apply(module, :get_version, [entity])
    version - length(events)
  end

  defp clear_pending_events(module, entity) do
    apply(module, :clear_pending_events, [entity])
  end

  defp get_events_from_aggregate(module, entity) do
    apply(module, :get_pending_events, [entity])
  end

  defp events_to_spear_events(events) do
    events
    |> Enum.map(&event_to_spear_event/1)
  end

  defp event_to_spear_event(event) do
    Spear.Event.new(event.type, event.body)
  end

  defp spear_events_to_events(events) do
    events
    |> Enum.map(&spear_event_to_event/1)
  end

  defp spear_event_to_event(event) do
    Event.new(event.type, event.body)
  end
end
