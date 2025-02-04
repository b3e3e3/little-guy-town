#ifndef FLAG_EVENT
#define FLAG_EVENT

#include "event.h"

namespace godot {

class FlagEvent : public Event
{
	GDCLASS(FlagEvent, Event)

protected:
	StringName p_flag_name;
	bool p_value;

public:
	static void _bind_methods();

	FlagEvent();
	~FlagEvent();

	GETSET(StringName, flag_name, p_flag_name)

	GETSET(bool, value, p_value)

	// Implement the virtual functions from Event
	virtual void _event_process() override;
	// virtual void _on_finished() override;
	// virtual void _create() override;
};
} // namespace godot
#endif