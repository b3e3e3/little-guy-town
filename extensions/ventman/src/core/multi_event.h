#ifndef MULTI_EVENT
#define MULTI_EVENT

#include "event.h"
#include <godot_cpp/templates/list.hpp>
#include <godot_cpp/variant/typed_array.hpp>

namespace godot {

class MultiEvent : public Event
{
	GDCLASS(MultiEvent, Event)

public:
	enum ListMode
	{
		// Loop over the queue
		QUEUE_LOOP,
		// Run all events at once
		RUN_ALL_AT_ONCE,
		// Clear each event from queue as it runs
		QUEUE_CLEAR_WHEN_DONE,
		// Clear each event from queue as it runs, but loop the last one
		QUEUE_CLEAR_AND_LOOP_LAST,
	};

protected:
	ListMode p_list_mode;
	TypedArray<Event> p_events;

public:
	static void _bind_methods();

	MultiEvent();

	void set_list_mode(const int &value) { p_list_mode = (ListMode)value; }
	int get_list_mode() { return (int)p_list_mode; }

	GETSET(TypedArray<Event>, events, p_events)

	void reset();

	TypedArray<Event> get_ready_events();

	void reset_all();

	void on_event_finished(Ref<Event> event, TypedArray<Event> ready_events);

#pragma region Virtuals
	void internal_event_process() override;
#pragma endregion
};
} // namespace godot
VARIANT_ENUM_CAST(MultiEvent::ListMode)

#endif