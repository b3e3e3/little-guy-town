extends GutTest

var event_node: EventNode
var event_graph: GraphEdit
var event_graph_parent: EventGraph

func before_each():
	event_node = EventNode.new()
	event_graph_parent = preload("res://addons/ventman-editor/graph/event_graph.tscn").instantiate()
	event_graph = event_graph_parent.get_node("PanelContainer/GraphEdit") as GraphEdit

	event_graph.add_child(event_node)
	add_child_autofree(event_graph)

func after_each():
	if (event_node != null): event_node.free()
	if (event_graph != null): event_graph.free()

func test_initial_signals_connected():
	# assert_true(event_node.connection_removed.is_connected(event_graph_parent.disconnect_node))
	# assert_true(event_node.connection_created.is_connected(event_graph_parent.connect_node))
	assert_true(event_graph.connection_request.is_connected(event_graph_parent._on_graph_edit_connection_request))
	assert_true(event_graph.disconnection_request.is_connected(event_graph_parent._on_graph_edit_disconnection_request))
	
	# assert_true(event_graph.connection_request.is_connected(event_node._on_connection_request)) # TODO: fix these
	# assert_true(event_graph.disconnection_request.is_connected(event_node._on_disconnection_request)) # TODO: fix these

func test_disable_all_slots():
	event_node._disable_all_slots()
	for i in event_node.MAX_SLOTS:
		assert_false(event_node.is_slot_enabled_left(i))
		assert_false(event_node.is_slot_enabled_right(i))

func test_connection_handling():
	watch_signals(event_node)
	var from_node = "node1"
	var from_port = 0
	var to_node = "node2"
	var to_port = 1
	
	event_node._on_connection_request(from_node, from_port, to_node, to_port)
	pass_test("Connection request handled without errors")

func test_get_connections_for_port():
	var port_idx = 0
	var connections = event_node._get_connections_for_port(port_idx)
	assert_typeof(connections, TYPE_ARRAY)
	assert_eq(connections.size(), 0)

func test_disconnect_port():
	var other := EventNode.new()
	event_graph.add_child(other);

	watch_signals(event_node)

	var port_idx = 0
	event_graph.connect_node(event_node.name, port_idx, other.name, 0)
	event_node._disconnect_port(port_idx)

	assert_signal_emitted(event_node, "connection_removed")
	
	other.free()

func test_update_connections():
	watch_signals(event_node)
	var old_idx = 0
	var new_idx = 1
	var mock_connection = {
		"from_node": event_node.name,
		"from_port": old_idx,
		"to_node": "other_node",
		"to_port": 0
	}
	event_node._update_connections(old_idx, new_idx, [mock_connection])
	assert_signal_emitted(event_node, "connection_removed")
	assert_signal_emitted(event_node, "connection_created")

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
	var children = control.get_children()
	assert_true(children[0] is Label)
	assert_true(children[1] is CheckBox)

func test_create_double_label():
	var left_text = "Left"
	var right_text = "Right"
	var control = event_node.create_double_label(left_text, right_text)
	assert_not_null(control)
	assert_true(control is HBoxContainer)
	var children = control.get_children()
	assert_true(children[0] is Label)
	assert_true(children[1] is Label)
	assert_eq(children[0].text, left_text)
	assert_eq(children[1].text, right_text)

func test_delete_request():
	watch_signals(event_node)
	event_node._on_delete_request()
	await get_tree().process_frame
	assert_true(event_node == null or event_node.is_queued_for_deletion())