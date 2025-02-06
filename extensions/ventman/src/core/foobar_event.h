#ifndef FOOBAR_EVENT
#define FOOBAR_EVENT

#include "event.h"
#include <godot_cpp/classes/time.hpp>

namespace godot {

class FoobarEvent : public Event
{
	GDCLASS(FoobarEvent, Event)

protected:
	String p_id;

public:
	FoobarEvent();

	static void _bind_methods() {}

	void internal_event_process() override;
};
} // namespace godot
#endif