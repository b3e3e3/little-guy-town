#include "flags.h"
#include "godot_cpp/variant/dictionary.hpp"

using namespace godot;

Flags *Flags::main = nullptr;

Flags::Flags()
{
	p_flags = Dictionary();
	if (!main) {
		main = this;
	}
}

void Flags::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("set_flag", "flag_name", "value"), &Flags::set_flag);
	ClassDB::bind_method(D_METHOD("get_flag", "flag_name"), &Flags::get_flag);

	ClassDB::bind_method(D_METHOD("get_flags"), &Flags::get_flags);

	ClassDB::bind_static_method("Flags", D_METHOD("get_main"), &Flags::get_main);
	// ClassDB::bind_method(D_METHOD("get_main"), &Flags::get_main);

	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "main", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY), "", "get_main");
	ADD_PROPERTY(PropertyInfo(Variant::DICTIONARY, "flags", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY), "", "get_flags");
}

Dictionary Flags::get_flags()
{
	return p_flags;
}

bool Flags::get_flag(const String &flag_name)
{
	return p_flags.has(flag_name) ? bool(p_flags[flag_name]) : false;
}

void Flags::set_flag(const String &flag_name, const bool value)
{
	p_flags[flag_name] = value;
}
godot::Flags *godot::Flags::get_main()
{
	if (!main) {
		main = memnew(Flags);
	}
	return main;
}
