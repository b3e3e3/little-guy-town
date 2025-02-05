#include "event.h"
#include "godot_cpp/core/class_db.hpp"

using namespace godot;

void Event::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("set_success", "value"), &Event::set_success);
	ClassDB::bind_method(D_METHOD("get_success"), &Event::get_success);

	ClassDB::bind_method(D_METHOD("step"), &Event::step);
	ClassDB::bind_method(D_METHOD("reset"), &Event::reset);
	ClassDB::bind_method(D_METHOD("finish"), &Event::finish);

	ClassDB::bind_method(D_METHOD("_event_process"), &Event::_event_process);
	ClassDB::bind_method(D_METHOD("_on_finished"), &Event::_on_finished);
	// ClassDB::bind_method(D_METHOD("_create"), &Event::_create);

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

void Event::_event_process()
{
	UtilityFunctions::print("event default behavior");
	call_deferred("finish");
}
void Event::_on_finished() {}
// void Event::_create() {}