extends AnimatedSprite2D

enum Direction {
	Left = -1,
	Right = 1,
}

@export var which_way_the_actual_sprite_image_is_drawn: Direction
		
var current_dir: Vector2

func get_facing_dir(velocity: Vector2) -> int:
	return sign(int(velocity.x))

func _ready():
	play_idle()
	
func _physics_process(delta):
	var facing := get_facing_dir(current_dir)
	flip_h = facing != which_way_the_actual_sprite_image_is_drawn
	
func play_run():
	animation = &"run"
	play()
	
func play_idle():
	animation = &"idle"
	play()

func _on_player_move(velocity):
	current_dir = velocity
	if animation == &"idle":
		play_run()

func _on_player_stop():
	play_idle()
