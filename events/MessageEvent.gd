extends Event
class_name MessageEvent

@export var messages: Array[String]
var _textbox
var textbox: Textbox:
	get:
		if _textbox == null:
			set_textbox(Util.get_main_textbox())
		return _textbox
	set(val):
		set_textbox(val)
#
func set_textbox(new: Textbox):
	print("set textbox\n", new)
	_textbox = new

func _event_process():
	print("Starting message event with %s message(s)" % messages.size())
	if !messages.is_empty():
		textbox.finished.connect(_on_textbox_finished, CONNECT_ONE_SHOT)
		for m in messages:
			textbox.queue_text(m)
	
func _on_textbox_finished():
	finish()
	
func set_messages(array_or_string: Variant):
	assert(typeof(array_or_string) == TYPE_STRING or typeof(array_or_string) == TYPE_ARRAY)
	
	match typeof(array_or_string):
		TYPE_STRING:
			messages.push_back(array_or_string)
		TYPE_ARRAY:
			messages.assign(array_or_string)
