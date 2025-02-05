#include "foobar_event.h"

using namespace godot;

void FoobarEvent::_event_process()
{
	UtilityFunctions::print("Foobar! " + p_id);
	Event::_event_process();
}
godot::FoobarEvent::FoobarEvent() :
		Event()
{
	p_id = String::num_int64(Time::get_singleton()->get_unix_time_from_system());
}
