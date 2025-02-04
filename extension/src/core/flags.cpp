#include "flags.h"

using namespace godot;

Dictionary Flags::p_flags;

void Flags::_bind_methods()
{
	ClassDB::bind_static_method("Flags", D_METHOD("set_flag", "flag_name", "value"), &Flags::set_flag);
	ClassDB::bind_static_method("Flags", D_METHOD("get_flag", "flag_name"), &Flags::get_flag);
}

Dictionary Flags::get_flags()
{
	return p_flags;
}

bool Flags::get_flag(const String &flag_name)
{
	return p_flags[flag_name];
}

void Flags::set_flag(const String &flag_name, const bool value)
{
	p_flags[flag_name] = value;
}