#ifndef EVENT
#define EVENT

// #include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/core/class_db.hpp>

#include "../util/getset.hpp"

namespace godot {

class Event : public Resource
{
	GDCLASS(Event, Resource)

	// public:
	// 	enum Status
	// 	{
	// 		NOT_STARTED,
	// 		IN_PROGRESS,
	// 		HAS_FINISHED
	// 	};

protected:
	Variant p_success;

	// Status p_staxtus;
	Callable p_callback;

public:
	static void _bind_methods();

	Event();
	~Event();

	void step();
	void reset();
	void finish();

	GETSET(bool, success, p_success)

	// int get_status() const { return (int)p_status; }
	// void set_status(const int &value) { p_status = (Status)value; }

	virtual void _event_process();
	virtual void _on_finished();
	virtual void _create();
	// virtual void _init();
};

} // namespace godot
// VARIANT_ENUM_CAST(Event::Status);x
#endif