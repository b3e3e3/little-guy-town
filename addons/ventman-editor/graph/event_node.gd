extends GraphNode
class_name EventNode

const TYPE_EVENT = 0

@onready var event := FlagEvent.new()

func create_double_label(left_text: String, right_text: String) -> Control:
	var box := HBoxContainer.new()
	var left := Label.new()
	var right := Label.new()
	
	left.text = left_text
	right.text = right_text
	
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	left.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# TODO: minimum size
	
	box.add_child(left)
	box.add_child(right)
	
	return box

func add_control(control: Control) -> void:
	add_child(control)

# Called when the node enters the scene tree for the first time.
func _ready():
	event.flag_name = ""
	event.value = true
	
	# Create input/output labels
	var label := create_double_label("In", "Out")
	add_control(label)
	
	set_slot(
		0,
		true,
		TYPE_EVENT,
		Color.YELLOW,
		true,
		TYPE_EVENT,
		Color.YELLOW
	)
	
	#var line_edit := LineEdit.new()
	#line_edit.placeholder_text = "flag name"
	#add_control(line_edit)
	#
	#var checkbox := CheckBox.new()
	#checkbox.button_pressed = event.value
	#add_control(checkbox)


func _on_delete_request():
	queue_free()
