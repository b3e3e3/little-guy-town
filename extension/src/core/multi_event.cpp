#include "multi_event.h"
#include "godot_cpp/core/class_db.hpp"

using namespace godot;

MultiEvent::MultiEvent() :
		Event()
{
	p_success = false;
}

void MultiEvent::_bind_methods()
{
	// ClassDB::bind_method(D_METHOD("set_list_mode", "value"), &MultiEvent::set_list_mode);
	// ClassDB::bind_method(D_METHOD("get_list_mode"), &MultiEvent::get_list_mode);

	ClassDB::bind_method(D_METHOD("set_events", "value"), &MultiEvent::set_events);
	ClassDB::bind_method(D_METHOD("get_events"), &MultiEvent::get_events);

	ADD_PROPERTY(PropertyInfo(Variant::INT, "list_mode"), "set_list_mode",
			"get_list_mode");
	ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "events"), "set_events",
			"get_events"); // TODO: readonly

	// BIND_ENUM_CONSTANT(QUEUE_LOOP)
	// BIND_ENUM_CONSTANT(RUN_ALL_AT_ONCE)
	// BIND_ENUM_CONSTANT(QUEUE_CLEAR_WHEN_DONE)
	// BIND_ENUM_CONSTANT(QUEUE_CLEAR_AND_LOOP_LAST)
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

	// for (const Event &element : p_events) {
	// 	if (element.get_status() == EventStatus::NOT_STARTED) {
	// 		filtered.append(element);
	// 	}
	// }
	return filtered;
}
void godot::MultiEvent::on_event_finished(Ref<Event> event, TypedArray<Event> ready_events)
{
	// switch (p_list_mode) {
	// 	case ListMode::QUEUE_LOOP:
	// 		// if this is the last event, reset all events
	// 		if (ready_events.size() == 1) {
	// 			for (int i = 0; i < p_events.size(); i++) {
	// 				Ref<Event> e = p_events[i];
	// 				// e.instantiate();
	// 				e->reset();
	// 			}
	// 		}
	// 		break;
	// 	case ListMode::RUN_ALL_AT_ONCE:
	// 		// if we have more events than this one ready, run again
	// 		if (ready_events.size() > 1) {
	// 			call_deferred("_event_process"); // TODO: deferred?
	// 			return; // don't finish
	// 		}
	// 		else {
	// 			// if this is the last event, reset all events to be run again
	// 			for (int i = 0; i < p_events.size(); i++) {
	// 				Ref<Event> e = p_events[i];
	// 				// e.instantiate();
	// 				e->reset();
	// 			}
	// 		}
	// 		break;
	// 	case ListMode::QUEUE_CLEAR_WHEN_DONE:
	// 		break; // do nothing i guess?
	// 	case ListMode::QUEUE_CLEAR_AND_LOOP_LAST:
	// 		// don't reset last event
	// 		if (ready_events.size() == 1) {
	// 			event->reset();
	// 		}
	// 		break;
	// }

	// finish after the event does. this line is never reached for
	// RUN_ALL_AT_ONCE
	finish();
}
void godot::MultiEvent::_event_process()
{
	// get events that have not been started yet
	TypedArray<Event> ready_events = get_ready_events();

	// get next event
	// Event &event = ready_events.front()->get();
	Ref<Event> event = ready_events.front();
	// event.instantiate();

	// start the ready event
	event->step();

	event->connect("finished",
			callable_mp(this, &MultiEvent::on_event_finished)
					.bind(&event, &ready_events),
			ConnectFlags::CONNECT_ONE_SHOT);
}
