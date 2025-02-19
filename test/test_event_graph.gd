extends GutTest

var event_node: EventNode
var graph_edit: GraphEdit

func before_each():
	event_node = EventNode.new()
	graph_edit = GraphEdit.new()
	graph_edit.add_child(event_node)
	add_child_autofree(graph_edit)

func after_each():
	event_node.free()
	graph_edit.free()

func test_initial_slot_states():
	event_node._disable_all_slots()
	for i in event_node.MAX_SLOTS:
		assert_false(event_node.is_slot_enabled_left(i))
		assert_false(event_node.is_slot_enabled_right(i))

func test_connection_request_signal():
	# Since _on_connection_request only prints to console, we can only verify 
	# that the method doesn't crash when called with valid parameters
	var from_node = "node1"
	var from_port = 0
	var to_node = "node2"
	var to_port = 1
	
	event_node._on_connection_request(from_node, from_port, to_node, to_port)
	# The method completed without throwing an error
	pass_test("Connection request handled without errors")

func test_get_connections_for_port():
	var port_idx = 0
	var connections = event_node._get_connections_for_port(port_idx)
	assert_typeof(connections, TYPE_ARRAY)
	# Initially should be empty as no connections exist
	assert_eq(connections.size(), 0)

func test_disconnect_port():
	watch_signals(event_node)
	var port_idx = 0
	
	# Setup mock connection data
	var mock_connection = {
		"from_node": event_node.name,
		"from_port": port_idx,
		"to_node": "other_node",
		"to_port": 0
	}
	
	# Add mock connection to graph
	graph_edit.connect_node(mock_connection.from_node,
						  mock_connection.from_port,
						  mock_connection.to_node,
						  mock_connection.to_port)
	
	event_node._disconnect_port(port_idx)
	assert_signal_emitted(event_node, "connection_removed")

func test_create_editor_control_string():
	var string_prop = {
		"name": "test_string",
		"type": TYPE_STRING
	}
	var control = event_node.create_editor_control(string_prop, "test", func(): pass )
	assert_not_null(control)
	assert_true(control is VBoxContainer)
	assert_true(control.get_child(0) is LineEdit)

func test_create_editor_control_bool():
	var bool_prop = {
		"name": "test_bool",
		"type": TYPE_BOOL
	}
	var control = event_node.create_editor_control(bool_prop, true, func(): pass )
	assert_not_null(control)
	assert_true(control is HBoxContainer)
	assert_true(control.get_child(1) is CheckBox)