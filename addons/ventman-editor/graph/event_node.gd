extends GraphNode
class_name EventNode

signal connection_removed(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal connection_created(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int)

const MAX_SLOTS = 32
const G_TYPE_EVENT = 0

@onready var event_list_node: Resource = preload("event_list.tscn")

@export var event: Event

#region Setup
func _connect_to_graph() -> void:
	var parent := get_parent()
	if parent is GraphEdit:
		# Disconnect existing connections first to prevent duplicates
		if connection_removed.is_connected(parent.disconnect_node):
			connection_removed.disconnect(parent.disconnect_node)
		if connection_created.is_connected(parent.connect_node):
			connection_created.disconnect(parent.connect_node)
			
		connection_removed.connect(parent.disconnect_node)
		connection_created.connect(parent.connect_node)
		parent.connection_request.connect(_on_connection_request)
		parent.disconnection_request.connect(_on_disconnection_request)
		parent.child_exiting_tree.connect(_on_node_deleted) # Add this line
	else:
		push_error("Event node parent is not GraphNode. %s" % [parent.get_path()])

func _ready() -> void:
	var connect_func = func():
		_connect_to_graph()
	
	if get_parent():
		connect_func.call()
	else:
		tree_entered.connect(connect_func, CONNECT_ONE_SHOT)
#endregion

#region Connections
func _disable_all_slots():
	for i in MAX_SLOTS:
		set_slot_enabled_left(i, false)
		set_slot_enabled_right(i, false)

func _update_slots() -> void: pass # TODO

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	print("Tried to connect from %s(%s) to %s(%s)" % [from_node, from_port, to_node, to_port])

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	print("Tried to disconnect from %s(%s) to %s(%s)" % [from_node, from_port, to_node, to_port])

func _get_connections_for_port(port_idx: int) -> Array:
	return get_parent().get_connection_list().filter(func(c):
		return (c.from_node == name and c.from_port == port_idx) or \
			   (c.to_node == name and c.to_port == port_idx))

func _disconnect_port(port_idx: int) -> void:
	var connections = _get_connections_for_port(port_idx)
	for c in connections:
		connection_removed.emit(c.from_node, c.from_port, c.to_node, c.to_port)

func _update_connections(old_idx: int, new_idx: int, connections: Array = []) -> void:
	connections = connections if connections else _get_connections_for_port(old_idx)
	
	for c in connections:
		connection_removed.emit(c.from_node, c.from_port, c.to_node, c.to_port)

		# TODO: does base event node need this? refactored from multieventnode
		if new_idx >= 0: # Skip reconnection if new_idx is negative (for removal)
			var from_node = c.from_node if c.from_node != name else name
			var from_port = new_idx if c.from_node == name else c.from_port
			var to_node = c.to_node if c.to_node != name else name
			var to_port = new_idx if c.to_node == name else c.to_port
			connection_created.emit(from_node, from_port, to_node, to_port)
#endregion

#region Nodes & Graph
func _on_node_deleted(node: Node) -> void: pass
#endregion

func setup_editor_for_event(event: Event):
	var properties = event.get_editable_properties()
	
	for prop in properties:
		var valid_types := [TYPE_STRING, TYPE_STRING_NAME, TYPE_OBJECT, TYPE_BOOL, TYPE_ARRAY] # TODO: dict
		if prop["type"] in valid_types:
			var current_value: Variant = event.get(prop["name"])
			if current_value == null:
				continue
				
			var on_changed := func(new_value = null):
				if new_value:
					event.set(prop["name"], new_value)
			
			var control := create_editor_control(prop, current_value, on_changed)
			if control:
				add_child(control)
			
			#_changed.connect(on_changed)

func create_editor_control(prop: Dictionary, default_value: Variant, on_changed: Callable) -> Control:
	var c: Control
	var _changed: Signal
	print("prop: ", prop)
	
	match (typeof(default_value)):
		TYPE_STRING, TYPE_STRING_NAME:
			c = VBoxContainer.new()
			#var label := Label.new()
			#
			#label.text = prop["name"]
			#label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var line := LineEdit.new()
			line.placeholder_text = prop["name"]
			
			line.text_changed.connect(on_changed)
			
			#c.add_child(label)
			c.add_child(line)
		TYPE_BOOL:
			c = HBoxContainer.new()
			var box := CheckBox.new()
			var label := Label.new()
			
			label.text = prop["name"]
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			box.alignment = HORIZONTAL_ALIGNMENT_RIGHT
			box.button_pressed = default_value
			
			box.toggled.connect(on_changed)
			
			c.add_child(label)
			c.add_child(box)
		TYPE_ARRAY:
			var arr := default_value as Array

			if arr.size() == 0:
				return null
			
			if arr[0] is Event:
				# TODO: custom node type?
				# we need to create an output slot that, when connected to,
				# creates a new output slot for the next event
				# then the original output slot is connected to the input slot of the original event
				# start code
				var vbox := VBoxContainer.new()
				var label := Label.new()
				label.text = prop["name"]
				label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				vbox.add_child(label)
				
				pass
			
			c = VBoxContainer.new()
			# var event_list: EventList = event_list_node.instantiate()
		_:
			push_warning("Unhandled Event prop type '%s'" % prop["type"])
	
	#print("EVENT INFO: %s %s %s" % [type_string(type), hint, hint_string])
	return c

func create_double_label(left_text: String, right_text: String) -> Control:
	var box := HBoxContainer.new()
	var left := Label.new()
	var right := Label.new()
	
	left.text = left_text
	right.text = right_text
	
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	left.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# TODO: minimum size
	
	box.add_child(left)
	box.add_child(right)
	
	return box

func add_control(control: Control) -> void:
	add_child(control)

# Called when the node enters the scene tree for the first time.
# func _ready():
# 	#event.flag_name = ""
# 	#event.value = true
	
# 	# create input/output labels
# 	var label_in_out := create_double_label("In", "Out")
# 	add_control(label_in_out)
# 	set_slot(
# 		0,
# 		true,
# 		G_TYPE_EVENT,
# 		Color.YELLOW,
# 		true,
# 		G_TYPE_EVENT,
# 		Color.YELLOW
# 	)
			
# 	#var line_edit := LineEdit.new()
# 	#line_edit.placeholder_text = "flag name"
# 	#add_control(line_edit)
# 	#
# 	#var checkbox := CheckBox.new()
# 	#checkbox.button_pressed = event.value
# 	#add_control(checkbox)


func _on_delete_request():
	queue_free()
