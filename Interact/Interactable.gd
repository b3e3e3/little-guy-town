extends StaticBody2D
class_name Interactable

signal interacted(with: Node)
signal finished


func _ready():
	finished.connect(_on_finish)
	interacted.connect(_on_interacted)

func _exit_tree():
	finished.disconnect(_on_finish)
	interacted.disconnect(_on_interacted)


func interact(with: Node):
	#print_debug("interaction started")
	interacted.emit(with)

func finish():
	#print_debug("interaction finished")
	finished.emit()
	

func _on_interacted(with: Node):
	pass
	
func _on_finish():
	pass
