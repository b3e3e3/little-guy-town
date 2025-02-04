extends Interactable
 
@export var current_event: Event

func _on_event_finished():
	finish()

func _on_interacted(with: Node):
	if current_event:
		current_event.finished.connect(_on_event_finished, CONNECT_ONE_SHOT)
		current_event.step()
	else:
		finish()
