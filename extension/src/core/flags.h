#ifndef FLAGS
#define FLAGS

#include "godot_cpp/core/object.hpp"
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/dictionary.hpp>

namespace godot {
class Flags : public RefCounted
{
	GDCLASS(Flags, RefCounted)

private:
	static Flags *main;
	Dictionary p_flags;

public:
	static Flags *get_main();

	Flags();
	~Flags() {}

	static void _bind_methods();

	Dictionary get_flags();

	bool get_flag(const String &flag_name);
	void set_flag(const String &flag_name, const bool value);
};
} //namespace godot
#endif