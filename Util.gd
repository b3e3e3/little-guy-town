extends Node

var main_textbox_scene: PackedScene = preload("res://Textbox.tscn")
@onready var main_textbox: Textbox = main_textbox_scene.instantiate()

func _ready():
	get_tree().current_scene.add_child(main_textbox)

var flags := {
	&"test": false,
}

func get_main_textbox() -> Textbox:
	return main_textbox

func register_flag(name: StringName, default_value: Variant) -> Variant:
	return flags.get_or_add(name, default_value)
	
func get_flag(flag_name: StringName) -> bool:
	return flags.get(flag_name) or false
	
func set_flag(flag_name: StringName, value: Variant):
	print("flag %s set to %s" % [flag_name, value])
	if flags.has(flag_name):
		flags[flag_name] = value
	else:
		register_flag(flag_name, value)
