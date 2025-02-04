extends Area2D

signal interacted(with: Node)

var _target: Node2D = null

func _ready():
	area_entered.connect(set_target)
	area_exited.connect(clear_target.unbind(1))
	
	body_entered.connect(set_target)
	body_exited.connect(clear_target.unbind(1))
	
func set_target(target: Node2D):
	_target = target
	
func clear_target():
	_target = null

func interact():
	if _target != null:
		interacted.emit(_target)
