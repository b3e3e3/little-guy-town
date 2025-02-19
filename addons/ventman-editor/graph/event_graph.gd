extends Control
class_name EventGraph

@onready var graph: GraphEdit = $PanelContainer/GraphEdit

@export var initial_pos := Vector2(50, 50)
@export var new_node_offset := Vector2(30, 30)
@export var node_scene: PackedScene = preload("event_node.tscn")

var nodes: Dictionary[String, EventNode] = {}

func _ready():
	%GraphEdit.add_child(MultiEventNode.new())
	# pass

func _on_new_button_pressed():
	%AddEventMenu.popup_centered()
	%AddEventMenu.id_pressed.connect(select_event, CONNECT_ONE_SHOT)

func select_event(id: int):
	var event: Event = %AddEventMenu.instantiate_event(id)
	if event:
		create_event_node(event)

func set_all_select(selected: bool):
	for n in nodes.values():
		n.selected = selected

func create_event_node(event: Event):
	var new_node := node_scene.instantiate() as EventNode
	# TODO: smaller subtitle next to title with event type
	
	new_node.title += "%s (%s)" % [nodes.size(), event.get_class().get_basename()]
	new_node.position_offset += initial_pos + (nodes.size() * new_node_offset)
	
	nodes[new_node.title] = new_node
	graph.add_child(new_node)
	
	new_node.setup_editor_for_event(event)
	
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
		nodes.erase((node as EventNode).title)

func _on_graph_edit_cut_nodes_request():
	pass # Replace with function body.


func _on_graph_edit_copy_nodes_request():
	pass # Replace with function body.


func _on_graph_edit_duplicate_nodes_request():
	pass # Replace with function body.
