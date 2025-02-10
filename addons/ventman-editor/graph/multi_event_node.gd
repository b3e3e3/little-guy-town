extends EventNode
class_name MultiEventNode

var add_button: Button
var node_dropdown: OptionButton

func _ready():
	add_button = Button.new()
	add_button.text = "Add Event"
	add_button.connect("pressed", _add_event_ui)
	
	# Create and setup node dropdown
	node_dropdown = OptionButton.new()
	node_dropdown.add_item("Global Option 1", 0)
	node_dropdown.add_item("Global Option 2", 1)
	node_dropdown.add_item("Global Option 3", 2)
	node_dropdown.connect("item_selected", _on_node_dropdown_selected)
	
	# Create a container for the controls
	var controls = HBoxContainer.new()
	controls.name = "Controls" # Set a name to identify it
	controls.add_child(add_button)
	controls.add_child(node_dropdown)
	
	add_child(controls)
	
	# var connect_func = func():
	# 	_connect_to_graph()
	
	# if get_parent():
	# 	connect_func.call()
	# else:
	# 	tree_entered.connect(connect_func, CONNECT_ONE_SHOT)
	super._ready()
	
	if event is MultiEvent:
		for sub_event in event.events:
			_add_event_ui(sub_event)

# override
func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if from_node == name:
		var event_row = get_child(from_port)
		if event_row is HBoxContainer:
			event_row.modulate = Color(1.0, 1.0, 1.0, 0.7) # Visual feedback
			var target_node = get_parent().get_node(NodePath(to_node))
			var label = event_row.get_child(0)
			label.text = target_node.title

# override
func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if from_node == name:
		# Reset the label when disconnected
		var event_row = get_child(from_port)
		if event_row is HBoxContainer:
			var label = event_row.get_child(0)
			label.text = "New Event"

#region Event
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

# TODO: refactor into "get connectable nodes" or something idk
func _get_event_rows() -> Array[HBoxContainer]:
	var nodes = get_children()
	var event_rows: Array[HBoxContainer] = []
	for node in nodes:
		# Skip the controls container (which contains add_button and node_dropdown)
		if node is HBoxContainer and node != get_node_or_null("Controls"):
			event_rows.append(node)
	return event_rows

func get_event_data() -> Dictionary:
	var data = {
		"type": "MultiEvent",
		"node_option": node_dropdown.selected,
		"events": _get_event_rows().map(func(c):
			return {
				"name": c.get_child(0).text,
				# "option": c.get_child(1).selected
			})
	}
	return data

func set_event_data(data: Dictionary) -> void:
	if data.type != "MultiEvent":
		push_error("Invalid event type: %s" % data.type)
		return
	
	# Restore node dropdown state
	node_dropdown.selected = data.get("node_option", 0)
	
	# Clear existing rows
	var rows = _get_event_rows()
	for row in rows:
		_disconnect_port(row.get_index())
		remove_child(row)
		row.queue_free()
	
	# Add new rows with stored dropdown selections
	for event_data in data.events:
		var row = _add_event_ui(event_data)
		if row:
			var dropdown = row.get_child(1) as OptionButton
			dropdown.selected = event_data.get("option", 0) # Restore dropdown selection
	
	_update_slots()
#endregion

# override
func _update_slots() -> void:
	# First disable ALL slots
	_disable_all_slots()
	
	var event_rows = _get_event_rows()
	
	# Update slots using the array index rather than child index
	for i in event_rows.size():
		var row = event_rows[i]
		var row_idx = row.get_index() # Get the actual index in the node's children
		
		# Set up slots based on position in event_rows array
		set_slot_enabled_left(row_idx, i == 0) # Only first event gets left slot
		set_slot_enabled_right(row_idx, true) # All events get right slot
		set_slot_color_left(row_idx, Color.WHITE)
		set_slot_color_right(row_idx, Color.WHITE)
		set_slot_type_left(row_idx, 0)
		set_slot_type_right(row_idx, 0)

#region UI
# func _on_dropdown_selected(row: HBoxContainer, index: int) -> void:
# 	var dropdown := row.get_child(1) as OptionButton
# 	var label := row.get_child(0) as Label
# 	# Do something with the selection
# 	print("Row %s selected option: %s" % [row.get_index(), dropdown.get_item_text(index)])

func _on_node_dropdown_selected(index: int) -> void:
	print("Node dropdown selected: %s" % node_dropdown.get_item_text(index))
	# Add your custom logic here

# override
func _on_node_deleted(node: Node) -> void:
	# Check if the deleted node was connected to any of our events
	var event_rows = _get_event_rows()
	for row in event_rows:
		var row_idx = row.get_index()
		var connections = _get_connections_for_port(row_idx)
		
		for c in connections:
			if (c.to_node == node.name) or (c.from_node == node.name):
				# Disconnect this connection
				connection_removed.emit(c.from_node, c.from_port, c.to_node, c.to_port)
				# Reset the label if this was our outgoing connection
				if c.from_node == name:
					var label = row.get_child(0)
					label.text = "New Event"
					row.modulate = Color.WHITE

func _add_event_ui(sub_event = null) -> HBoxContainer:
	if get_child_count() >= MAX_SLOTS: # GraphEdit typically has 32 max slots
		push_error("Cannot add more events: maximum slot limit reached")
		return null
		
	var row = HBoxContainer.new()
	var label := Label.new()
	# var dropdown := OptionButton.new()

	# Setup label
	label.set("text", sub_event.name if sub_event else "New Event")
	
	# Setup dropdown
	# dropdown.add_item("Option 1", 0)
	# dropdown.add_item("Option 2", 1)
	# dropdown.add_item("Option 3", 2)
	# dropdown.connect("item_selected", func(index): _on_dropdown_selected(row, index))
	
	# Add elements to row
	row.add_child(label)
	# row.add_child(dropdown)
	
	# Add control buttons
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

#endregion