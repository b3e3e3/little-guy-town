#ifndef FLAGS
#define FLAGS

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/dictionary.hpp>

namespace godot {
class Flags : public RefCounted
{
	GDCLASS(Flags, RefCounted)

private:
	static Dictionary p_flags;

public:
	static void _bind_methods();

	static Dictionary get_flags();

	static bool get_flag(const String &flag_name);
	static void set_flag(const String &flag_name, const bool value);
};
} //namespace godot
#endif