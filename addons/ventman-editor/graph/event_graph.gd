extends Control

@onready var graph: GraphEdit = $PanelContainer/GraphEdit

@export var initial_pos := Vector2(50, 50)
@export var new_node_offset := Vector2(30, 30)
@export var node_scene: PackedScene = preload("event_node.tscn")

var nodes: Array[GraphNode] = []

func set_all_select(selected: bool):
	for n in nodes:
		n.selected = selected

func _on_new_button_pressed():
	var new_node := node_scene.instantiate()
	#new_node.set_slot_enabled_left(0, true)
	#new_node.set_slot_color_left(0, Color.YELLOW)
	
	new_node.title += " %s" % nodes.size()
	
	new_node.position_offset += initial_pos + (nodes.size() * new_node_offset)
	
	nodes.append(new_node)
	graph.add_child(new_node)
	
	set_all_select(false)
	new_node.selected = true


func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	if from_node == to_node:
		print("Cannot connect node to itself")
		return
	graph.connect_node(from_node, from_port, to_node, to_port)


func _on_graph_edit_disconnection_request(from_node, from_port, to_node, to_port):
	graph.disconnect_node(from_node, from_port, to_node, to_port)


func _on_graph_edit_child_entered_tree(node):
	pass # Replace with function body.


func _on_graph_edit_delete_nodes_request(deleted_nodes: Array[StringName]):
	for n in deleted_nodes:
		var node := %GraphEdit.get_node(NodePath(n))
		node.queue_free()
		nodes.remove_at(nodes.find(node))

func _on_graph_edit_cut_nodes_request():
	pass # Replace with function body.


func _on_graph_edit_copy_nodes_request():
	pass # Replace with function body.


func _on_graph_edit_duplicate_nodes_request():
	pass # Replace with function body.


func _on_graph_edit_popup_request(at_position):
	pass # Replace with function body.
