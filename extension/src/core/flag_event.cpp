#include "flag_event.h"

using namespace godot;

void FlagEvent::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("set_flag_name", "value"), &FlagEvent::set_flag_name);
	ClassDB::bind_method(D_METHOD("get_flag_name"), &FlagEvent::get_flag_name);

	ClassDB::bind_method(D_METHOD("set_value", "value"), &FlagEvent::set_value);
	ClassDB::bind_method(D_METHOD("get_value"), &FlagEvent::get_value);

	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "flag_name"), "set_flag_name",
			"get_flag_name");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "value"), "set_value", "get_value");
}

FlagEvent::FlagEvent() :
		Event() {}

FlagEvent::~FlagEvent() {}

void FlagEvent::_event_process()
{
	// Flags::get_main()->set_flag(p_flag_name, p_value);
	// TODO: set flag
	Event::_event_process();
}