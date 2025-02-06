#ifndef EVENT
#define EVENT

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/core/class_db.hpp>

#include <godot_cpp/core/binder_common.hpp>
#include <godot_cpp/core/gdvirtual.gen.inc>

#include "../util/getset.hpp"
#include "godot_cpp/classes/wrapped.hpp"

#define EVENT_VIRTUAL_WRAPPER(method_name)             \
	void method_name()                                 \
	{                                                  \
		if (GDVIRTUAL_IS_OVERRIDDEN(_##method_name)) { \
			GDVIRTUAL_CALL(_##method_name);            \
			return;                                    \
		}                                              \
		internal_##method_name();                      \
	}

namespace godot {

class Event : public Resource
{
	GDCLASS(Event, Resource)

public:
	enum Status
	{
		NOT_STARTED,
		IN_PROGRESS,
		HAS_FINISHED
	};

protected:
	Variant p_success;

	Status p_status;
	Callable p_callback;

	void _on_stepped()
	{
		// UtilityFunctions::print("on stepped, even");
		Event::event_process();
	}

	void _on_finished()
	{
		// UtilityFunctions::print("on finished, even");
		Event::event_finished();
	}

public:
	static void _bind_methods();

	Event();
	~Event();

	void step();
	void reset();
	void finish();

	GETSET(bool, success, p_success)

	int get_status() const { return (int)p_status; }
	void set_status(const int &value) { p_status = (Status)value; }

	EVENT_VIRTUAL_WRAPPER(event_process)
	EVENT_VIRTUAL_WRAPPER(event_finished)
	EVENT_VIRTUAL_WRAPPER(event_create)

#pragma region Virtuals
	GDVIRTUAL0(_event_process)
	virtual void internal_event_process();

	GDVIRTUAL0(_event_finished)
	virtual void internal_event_finished();

	GDVIRTUAL0(_event_create)
	virtual void internal_event_create();
#pragma endregion
};

} // namespace godot
VARIANT_ENUM_CAST(Event::Status);
#endif