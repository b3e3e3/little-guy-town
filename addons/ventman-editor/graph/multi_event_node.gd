extends EventNode
class_name MultiEventNode

const MAX_SLOTS = 32

signal connection_removed(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal connection_created(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int)

var add_button: Button

func _ready():
	add_button = Button.new()
	add_button.text = "Add Event"
	add_button.connect("pressed", _add_event_ui)
	add_child(add_button)
	
	var connect_func = func():
		_connect_to_graph()
	
	if get_parent():
		connect_func.call()
	else:
		tree_entered.connect(connect_func, CONNECT_ONE_SHOT)
	
	if event is MultiEvent:
		for sub_event in event.events:
			_add_event_ui(sub_event)

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
	else:
		push_error("Event node parent is not GraphNode. %s" % [parent.get_path()])

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if from_node == name:
		# We're the source of the connection, update our event label
		var target_node = get_parent().get_node(NodePath(to_node))
		var event_row = get_child(from_port)
		if event_row is HBoxContainer:
			var label = event_row.get_child(0)
			label.text = target_node.title

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if from_node == name:
		# Reset the label when disconnected
		var event_row = get_child(from_port)
		if event_row is HBoxContainer:
			var label = event_row.get_child(0)
			label.text = "New Event"

func _add_event_ui(sub_event = null) -> HBoxContainer:
	if get_child_count() >= MAX_SLOTS: # GraphEdit typically has 32 max slots
		push_error("Cannot add more events: maximum slot limit reached")
		return null
		
	var row = HBoxContainer.new()
	var label := Label.new()

	label.set("text", sub_event.name if sub_event else "New Event")
	
	row.add_child(label)
	
	var buttons = [
		["X", _remove_event],
		["↑", _move_event, -1],
		["↓", _move_event, 1]
	]
	
	for btn_data in buttons:
		var btn = Button.new()
		btn.text = btn_data[0]
		btn.connect("pressed",
			func(): btn_data[1].call(row) if btn_data.size() == 2 \
			else btn_data[1].call(row, btn_data[2]))
		row.add_child(btn)
	
	add_child(row)
	move_child(row, get_child_count() - 2)
	_update_slots()
	return row

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
		if new_idx >= 0: # Skip reconnection if new_idx is negative (for removal)
			var from_node = c.from_node if c.from_node != name else name
			var from_port = new_idx if c.from_node == name else c.from_port
			var to_node = c.to_node if c.to_node != name else name
			var to_port = new_idx if c.to_node == name else c.to_port
			connection_created.emit(from_node, from_port, to_node, to_port)

func _remove_event(row: HBoxContainer) -> void:
	var idx = row.get_index()
	
	# First disconnect this port and update connections for remaining rows
	_disconnect_port(idx)
	
	# Update connections for remaining rows before removing the row
	var event_rows = _get_event_rows()
	for i in event_rows.size():
		var current_row = event_rows[i]
		var current_idx = current_row.get_index()
		if current_idx > idx:
			_update_connections(current_idx, current_idx - 1)
	
	# Now remove the row using queue_free() instead of immediate free
	remove_child(row)
	row.queue_free()
	
	_update_slots()

func _move_event(row: HBoxContainer, direction: int) -> void:
	if not row or not row.is_inside_tree():
		push_error("Invalid row or row not in tree")
		return
		
	var old_idx = row.get_index()
	var new_idx = old_idx + direction
	
	# Check if move is valid considering add_button
	if new_idx >= 0 and new_idx < get_child_count() - 1 and get_child(new_idx) != add_button:
		# Store all affected connections first
		var old_connections = _get_connections_for_port(old_idx)
		var swap_connections = _get_connections_for_port(new_idx)
		
		# Remove all affected connections
		_disconnect_port(old_idx)
		_disconnect_port(new_idx)
		
		# Move the row
		move_child(row, new_idx)
		
		# Reconnect all connections in the correct order
		for c in swap_connections:
			if c.from_node == name:
				connection_created.emit(name, old_idx, c.to_node, c.to_port)
			if c.to_node == name:
				connection_created.emit(c.from_node, c.from_port, name, old_idx)
				
		for c in old_connections:
			if c.from_node == name:
				connection_created.emit(name, new_idx, c.to_node, c.to_port)
			if c.to_node == name:
				connection_created.emit(c.from_node, c.from_port, name, new_idx)
		
		_update_slots()

func _get_event_rows() -> Array[HBoxContainer]:
	var nodes = get_children()
	var event_rows: Array[HBoxContainer] = []
	for node in nodes:
		if node is HBoxContainer and node != add_button:
			event_rows.append(node)
	return event_rows

func _update_slots() -> void:
	# First disable ALL slots
	for i in MAX_SLOTS:
		set_slot_enabled_left(i, false)
		set_slot_enabled_right(i, false)
	
	var event_rows = _get_event_rows()
	
	# Update slots using the array index rather than child index
	for i in event_rows.size():
		var row = event_rows[i]
		
		# Set up slots based on position in event_rows array
		set_slot_enabled_left(i, i == 0) # Only first event gets left slot
		set_slot_enabled_right(i, true) # All events get right slot
		set_slot_color_left(i, Color.WHITE)
		set_slot_color_right(i, Color.WHITE)
		set_slot_type_left(i, 0)
		set_slot_type_right(i, 0)

func get_event_data() -> Dictionary:
	return {
		"type": "MultiEvent",
		"events": _get_event_rows().map(func(c): return {"name": c.get_child(0).text})
	}

func set_event_data(data: Dictionary) -> void:
	if data.type != "MultiEvent":
		push_error("Invalid event type: %s" % data.type)
		return
		
	# Wait for existing rows to be freed before adding new ones
	var rows = _get_event_rows()
	for row in rows:
		_disconnect_port(row.get_index()) # Disconnect before removing
		remove_child(row)
		row.queue_free()
	
	# Add new rows
	for event_data in data.events:
		_add_event_ui(event_data)
	
	_update_slots()