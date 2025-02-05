#ifndef GUARD_EVENT
#define GUARD_EVENT

#include "event.h"

namespace godot {

class GuardEvent : public Event
{
	GDCLASS(GuardEvent, Event)

private:
	StringName p_flag_name;
	Ref<Event> p_true_event;
	Ref<Event> p_false_event;
	Ref<Event> p_current_event;

public:
	static void _bind_methods();

	GuardEvent();
	~GuardEvent();

	StringName get_flag_name() const { return p_flag_name; }
	void set_flag_name(const StringName &value) { p_flag_name = value; }

	Ref<Event> get_true_event() const { return p_true_event; }
	void set_true_event(const Ref<Event> &value) { p_true_event = value; }

	Ref<Event> get_false_event() const { return p_false_event; }
	void set_false_event(const Ref<Event> &value) { p_false_event = value; }

	Ref<Event> get_current_event() const { return p_current_event; }
	void set_current_event(const Ref<Event> &value) { p_current_event = value; }

	// Implement the virtual functions from Event
	void _event_process() override;
	void _on_finished() override {}
	void _create() override {}
};
} // namespace godot
#endif