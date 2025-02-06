#include "event.h"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/variant/utility_functions.hpp"

using namespace godot;

void Event::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("set_success", "value"), &Event::set_success);
	ClassDB::bind_method(D_METHOD("get_success"), &Event::get_success);

	ClassDB::bind_method(D_METHOD("step"), &Event::step);
	ClassDB::bind_method(D_METHOD("reset"), &Event::reset);
	ClassDB::bind_method(D_METHOD("finish"), &Event::finish);

	// ClassDB::bind_method(D_METHOD("_event_process"), &Event::event_process);
	// ClassDB::bind_method(D_METHOD("_event_finished"), &Event::event_finished);
	// ClassDB::bind_method(D_METHOD("_event_create"), &Event::event_create);

	ClassDB::bind_method(D_METHOD("_on_stepped"), &Event::_on_stepped);
	ClassDB::bind_method(D_METHOD("_on_finished"), &Event::_on_finished);

	BIND_VIRTUAL_METHOD(Event, /*internal_*/ event_process)
	BIND_VIRTUAL_METHOD(Event, /*internal_*/ event_finished)
	BIND_VIRTUAL_METHOD(Event, /*internal_*/ event_create)

	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "success"), "set_success",
			"get_success");

	ADD_SIGNAL(MethodInfo("stepped"));
	ADD_SIGNAL(MethodInfo("finished"));

	BIND_ENUM_CONSTANT(NOT_STARTED)
	BIND_ENUM_CONSTANT(IN_PROGRESS)
	BIND_ENUM_CONSTANT(HAS_FINISHED)
}

Event::Event()
{
	p_success = true;
	p_status = Status::NOT_STARTED;

	connect("stepped", Callable(this, "_on_stepped"));
	connect("finished", Callable(this, "_on_finished"));
}

Event::~Event() {}

void Event::step()
{
	p_status = Status::HAS_FINISHED;
	// p_status = Status::IN_PROGRESS;
	emit_signal("stepped");
}

void Event::reset()
{
	p_status = Status::NOT_STARTED;
}

void Event::finish()
{
	p_status = Status::HAS_FINISHED;
	emit_signal("finished");

	if (p_callback != Variant::NIL) {
		p_callback.call();
	}
}
#pragma region Virtuals
void godot::Event::internal_event_process()
{
	call_deferred("finish");
}
void godot::Event::internal_event_finished() {}
void godot::Event::internal_event_create() {}

#pragma endregion