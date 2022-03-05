defmodule Mabelsbookshelf.EventStoreDbClient do
  use Spear.Client, otp_app: :mabels_bookshelf

  def insert(module, entity, stream_name) do
    get_events_from_aggregate(module, entity)
    |> events_to_spear_events()
    |> append(stream_name, expect: :empty)
  end

  def update(module, entity, stream_name) do
    events = get_events_from_aggregate(module, entity)
    revision = calculate_revision(module, events, entity)

    events
    |> event_to_spear_event()
    |> append(stream_name, expect: revision)
  end

  def get(module, stream_name) do
    stream!(stream_name)
    |> apply_events(module)
  end

  defp apply_events(events, module) do
    Enum.reduce(events, struct(module), fn event, entity ->
      apply(module, :apply_event, [entity, event])
    end)
  end

  defp calculate_revision(module, events, entity) do
    version = apply(module, :get_version, [entity])
    version - length(events)
  end

  defp get_events_from_aggregate(module, entity) do
    apply(module, :get_pending_events, [entity])
  end

  defp events_to_spear_events(events) do
    events
    |> Enum.map(&event_to_spear_event/1)
  end

  defp event_to_spear_event(events) do
    Enum.map(events, fn event -> Spear.Event.new(event.type, Map.from_struct(event.body)) end)
  end
end
