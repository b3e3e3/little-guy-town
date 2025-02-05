#include "foobar_event.h"
#include "godot_cpp/classes/time.hpp"

using namespace godot;

void FoobarEvent::_event_process()
{
	UtilityFunctions::print("Foobar! " + String::num_int64(Time::get_singleton()->get_unix_time_from_system()));
	Event::_event_process();
}