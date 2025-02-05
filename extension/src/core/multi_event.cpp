#include "multi_event.h"
#include "godot_cpp/classes/global_constants.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/variant/utility_functions.hpp"

using namespace godot;

MultiEvent::MultiEvent() :
		Event()
{
	p_success = false;
}

void MultiEvent::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("set_list_mode", "value"), &MultiEvent::set_list_mode);
	ClassDB::bind_method(D_METHOD("get_list_mode"), &MultiEvent::get_list_mode);

	ClassDB::bind_method(D_METHOD("set_events", "value"), &MultiEvent::set_events);
	ClassDB::bind_method(D_METHOD("get_events"), &MultiEvent::get_events);

	ADD_PROPERTY(PropertyInfo(Variant::INT, "list_mode", PROPERTY_HINT_ENUM, "Queue Loop,Run All At Once,Queue Clear When Done,Queue Clear And Loop Last"), "set_list_mode",
			"get_list_mode");

	ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "events", PROPERTY_HINT_ARRAY_TYPE, String::num(Variant::OBJECT) + "/" + String::num(PROPERTY_HINT_RESOURCE_TYPE) + ":Event"),
			"set_events",
			"get_events");

	BIND_ENUM_CONSTANT(QUEUE_LOOP)
	BIND_ENUM_CONSTANT(RUN_ALL_AT_ONCE)
	BIND_ENUM_CONSTANT(QUEUE_CLEAR_WHEN_DONE)
	BIND_ENUM_CONSTANT(QUEUE_CLEAR_AND_LOOP_LAST)
}

void godot::MultiEvent::reset()
{
	p_success = false;
	Event::reset();
}
TypedArray<Event> godot::MultiEvent::get_ready_events()
{
	// TODO: not implemented
	TypedArray<Event> filtered;

	for (int i = 0; i < p_events.size(); i++) {
		Ref<Event> element = p_events[i];
		if (element->get_status() == Status::NOT_STARTED) {
			filtered.append(element);
		}
	}
	return filtered;
}

void MultiEvent::reset_all()
{
	for (int i = 0; i < p_events.size(); i++) {
		Ref<Event> e = p_events[i];
		e->reset();
	}
}

void godot::MultiEvent::on_event_finished(Ref<Event> event, TypedArray<Event> ready_events)
{
	UtilityFunctions::print("Ready events: " + String::num_int64(ready_events.size()));
	switch (p_list_mode) {
		case ListMode::QUEUE_LOOP:
			// if this is the last event, reset all events
			if (ready_events.size() == 1) {
				reset_all();
			}
			break;
		case ListMode::RUN_ALL_AT_ONCE:
			// if we have more events than this one ready, run again
			if (ready_events.size() > 1) {
				call_deferred("_event_process"); // TODO: deferred?
				return; // don't finish
			}
			else {
				// if this is the last event, reset all events to be run again
				reset_all();
			}
			break;
		case ListMode::QUEUE_CLEAR_WHEN_DONE:
			break; // do nothing i guess?
		case ListMode::QUEUE_CLEAR_AND_LOOP_LAST:
			// don't reset last event
			if (ready_events.size() == 1) {
				event->reset();
			}
			break;
	}

	// finish after the event does. this line is never reached for RUN_ALL_AT_ONCE
	call_deferred("finish");
}
void godot::MultiEvent::_event_process()
{
	// get events that have not been started yet
	TypedArray<Event> ready_events = get_ready_events();

	if (ready_events.size() > 0) {
		// get next event
		Ref<Event> event = ready_events.front();

		if (!event.is_null()) {
			// start the ready event
			event->step();

			event->connect("finished",
					callable_mp(this, &MultiEvent::on_event_finished)
							.bind(event, ready_events),
					ConnectFlags::CONNECT_ONE_SHOT);

			return; // early return so we dont... finish early... 😳
		}
	}

	call_deferred("finish");
}
