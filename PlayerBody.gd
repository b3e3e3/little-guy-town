extends CharacterBody2D

signal moving(velocity: Vector2)

func _physics_process(delta):
	move_and_slide()
	
	if !is_zero_approx(velocity.length_squared()):
		moving.emit(velocity)

func move(vel: Vector2):
	velocity = vel # TODO: acceleration?


func stop():
	velocity = Vector2.ZERO


func _on_player_move(velocity):
	move(velocity)


func _on_player_stop():
	stop()
