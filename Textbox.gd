extends CanvasLayer
class_name Textbox

signal started
signal progressed
signal finished

const CHAR_READ_RATE: float = 16

enum State {
	READY,
	READING,
	DONE,
}

var state: State = State.READY
var text_queue: Array[String] = []

var current_tween: Tween
@onready var container: Container = $TextboxContainer
@onready var label: Label = $TextboxContainer/MarginContainer/HBoxContainer/Label

func _ready():
	hide_textbox()
	#queue_text("ruh roh!")
	#queue_text("theres a bunch of messages here")
	#queue_text("i dont give a fuk")

func _process(delta):
	match state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
				started.emit()
		State.READING:
			if Input.is_action_just_pressed("confirm"):
				force_reading_finish()
		State.DONE:
			if Input.is_action_just_pressed("confirm"):
				progressed.emit()
				
				if text_queue.is_empty():
					hide_textbox()
					finished.emit()
				
				change_state(State.READY)

func force_reading_finish():
	current_tween.pause()
	current_tween.custom_step(999)

func hide_textbox():
	container.hide()
	
	label.text = "";

func show_textbox():
	container.show()
	
func queue_text(text: String):
	text_queue.push_back(text);
	
func display_text():
	var next_text: String = text_queue.pop_front()#pop_back()
	label.text = next_text
	
	change_state(State.READING)
	show_textbox()
	
	label.visible_ratio = 0.0
	
	current_tween = create_tween()
	current_tween.tween_property(label, "visible_ratio", 1.0, len(next_text) / CHAR_READ_RATE)
	
	await current_tween.finished
	finish_reading()
	
func finish_reading():
	change_state(State.DONE)

func change_state(new: State):
	state = new
	match state:
		State.READY:
			pass
		State.READING:
			pass
		State.DONE:
			pass
