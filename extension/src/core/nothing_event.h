#ifndef NOTHING_EVENT
#define NOTHING_EVENT

#include "event.h"

namespace godot {

class NothingEvent : public Event
{
	GDCLASS(NothingEvent, Event)

public:
	NothingEvent();
	~NothingEvent();
};
} // namespace godot
#endif