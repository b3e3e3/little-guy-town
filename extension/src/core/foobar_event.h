#ifndef FOOBAR_EVENT
#define FOOBAR_EVENT

#include "event.h"

namespace godot {

class FoobarEvent : public Event
{
	GDCLASS(FoobarEvent, Event)

public:
	static void _bind_methods() {}

	virtual void _event_process() override;
};
} // namespace godot
#endif