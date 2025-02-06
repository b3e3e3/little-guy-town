#include <gdextension_interface.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

#include "core/event.h"
#include "core/flag_event.h"
#include "core/flags.h"
#include "core/foobar_event.h"
#include "core/guard_event.h"
#include "core/multi_event.h"

using namespace godot;

void initialize_ventman_module(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	ClassDB::register_class<Flags>();
	// GDREGISTER_ABSTRACT_CLASS(Event);
	ClassDB::register_class<Event>();
	ClassDB::register_class<FlagEvent>();
	ClassDB::register_class<GuardEvent>();
	ClassDB::register_class<MultiEvent>();
	ClassDB::register_class<FoobarEvent>();
}

void uninitialize_ventman_module(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
}

extern "C"
{
	GDExtensionBool GDE_EXPORT library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address,
			const GDExtensionClassLibraryPtr p_library,
			GDExtensionInitialization *r_initialization)
	{
		GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

		init_obj.register_initializer(initialize_ventman_module);
		init_obj.register_terminator(uninitialize_ventman_module);

		return init_obj.init();
	}
}