defmodule MabelsBookshelf.Repo do
  alias MabelsBookshelf.Behaviors.Event

  def insert(module, entity, stream_name) do
    run_on_pool(&(insert(&1, module, entity, stream_name)))
  end

  defp insert(connection, module, entity, stream_name) do
    get_events_from_aggregate(module, entity)
    |> events_to_spear_events()
    |> Spear.append(connection, stream_name, expect: :empty)

    clear_pending_events(module, entity)
  end

  def update(module, entity, stream_name) do
    run_on_pool(&(update(&1, module, entity, stream_name)))
  end

  defp update(connection, module, entity, stream_name) do
    events = get_events_from_aggregate(module, entity)
    revision = calculate_revision(module, events, entity)

    events
    |> events_to_spear_events()
    |> Spear.append(connection, stream_name, expect: revision)

    clear_pending_events(module, entity)
  end

  def get(module, stream_name) do
    run_on_pool(&(get(&1, module, stream_name)))
  end

  defp get(connection, module, stream_name) do
    Spear.stream!(connection, stream_name)
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

  defp run_on_pool(action) do
    :poolboy.transaction(:spear_supervisor, fn pid ->
      action.(pid)
    end)
  end
end
