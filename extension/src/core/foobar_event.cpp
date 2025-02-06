#include "foobar_event.h"

using namespace godot;

void FoobarEvent::internal_event_process()
{
	UtilityFunctions::print("Foobar! " + p_id);
	Event::internal_event_process();
}
godot::FoobarEvent::FoobarEvent() :
		Event()
{
	p_id = String::num_int64(Time::get_singleton()->get_unix_time_from_system());
}
