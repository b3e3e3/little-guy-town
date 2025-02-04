#include <godot_cpp/core/class_db.hpp>

#include "flags.h"
#include "guard_event.h"

using namespace godot;

void GuardEvent::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("set_flag_name", "value"), &GuardEvent::set_flag_name);
	ClassDB::bind_method(D_METHOD("get_flag_name"), &GuardEvent::get_flag_name);

	ClassDB::bind_method(D_METHOD("set_true_event", "value"), &GuardEvent::set_true_event);
	ClassDB::bind_method(D_METHOD("get_true_event"), &GuardEvent::get_true_event);

	ClassDB::bind_method(D_METHOD("set_false_event", "value"), &GuardEvent::set_false_event);
	ClassDB::bind_method(D_METHOD("get_false_event"), &GuardEvent::get_false_event);

	ClassDB::bind_method(D_METHOD("set_current_event", "value"), &GuardEvent::set_current_event);
	ClassDB::bind_method(D_METHOD("get_current_event"), &GuardEvent::get_current_event);

	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "flag_name"), "set_flag_name",
			"get_flag_name");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "true_event"), "set_true_event",
			"get_true_event");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "false_event"), "set_false_event",
			"get_false_event");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "current_event"), "set_current_event",
			"get_current_event");
}

GuardEvent::GuardEvent() :
		Event() {}

GuardEvent::~GuardEvent() {}

void godot::GuardEvent::_event_process()
{
	UtilityFunctions::print("Checking guard");
	bool flag = Flags::get_flag(p_flag_name);

	Ref<Event> current_event = p_false_event;
	// current_event.instantiate();

	if (flag) {
		current_event = p_true_event;
	}
}
