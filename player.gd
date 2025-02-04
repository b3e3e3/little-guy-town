extends Node

@onready var saturn: SaturnStatePlayer = $SaturnStatePlayer

@export_category("Movement")
@export var speed: float = 100.0

var _is_moving: bool = false
var _is_interacting

signal pressed_interact
signal move(velocity: Vector2)
signal stop

var state: PlayerStateAdapter.State

var move_input: Vector2:
	get:
		return Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).sign()

func _ready():
	saturn.state_changed.connect(func ():
		state = saturn.get_state()
		#print(PlayerStateAdapter.State.keys()[state])
	)

func should_move() -> bool:
	var should_stop := is_zero_approx(move_input.length_squared())
	
	if should_stop:
		if _is_moving:
			stop.emit()
	else:
		move.emit(move_input.normalized() * speed)
	
	_is_moving = !should_stop
	return _is_moving

func process_movement(delta):
	saturn.set_argument("should_move", should_move())

func process_interact(delta):
	if Input.is_action_just_pressed("interact") \
		and state != PlayerStateAdapter.State.INTERACT \
	:
		pressed_interact.emit()

func _physics_process(delta):
	match state:
		PlayerStateAdapter.State.IDLE, PlayerStateAdapter.State.MOVE:
			process_movement(delta)
			process_interact(delta)
	
	saturn.set_argument("is_interacting", _is_interacting)

func _on_interaction_finished(with: Interactable):
	_is_interacting = false
	with.finished.disconnect(_on_interaction_finished)

func _on_interact_area_interacted(with):
	if with is Interactable:
		_is_interacting = true
			
		with.finished.connect(_on_interaction_finished.bind(with))
		with.interact(self)

#func _on_interactable_finished(with: Interactable):
	#with.finished.disconnect(_on_interactable_finished)
	#_is_interacting = false
