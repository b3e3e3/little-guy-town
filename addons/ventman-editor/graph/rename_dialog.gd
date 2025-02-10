extends ConfirmationDialog


var text: String = ""

func _on_line_edit_text_changed(new_text: String) -> void:
	text = new_text


func _on_focus_entered() -> void:
	print("Grab focus")
	$VBoxContainer/LineEdit.grab_focus()
