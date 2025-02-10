extends Control
class_name EventList

signal new_item(id: int)
signal duplicate_item(id: int)
signal move_up(id: int)
signal move_down(id: int)
signal delete_item(id: int)

const NEW_ITEM_ID = 0
const DUPLICATE_ITEM_ID = 1
const MOVE_UP_ID = 2
const MOVE_DOWN_ID = 3
const RENAME_ITEM_ID = 5
const DELETE_ITEM_ID = 4

@onready var rename_dialog: ConfirmationDialog = $RenameDialog
@onready var rc_menu: PopupMenu = $RightClickMenu
@onready var event_list: ItemList = $EventList

#region Right Click Menu
func create_list_item_popup_options(item_index: int = -1):
	rc_menu.clear();

	rc_menu.add_item("New...", NEW_ITEM_ID)
	rc_menu.add_item("Duplicate", DUPLICATE_ITEM_ID)
	rc_menu.add_separator()
	rc_menu.add_item("Move up", MOVE_UP_ID)
	rc_menu.add_item("Move down", MOVE_DOWN_ID)
	rc_menu.add_separator()
	rc_menu.add_item("Rename", RENAME_ITEM_ID)
	rc_menu.add_item("Delete :(", DELETE_ITEM_ID)
	
	if item_index < 0:
		rc_menu.set_item_disabled(DUPLICATE_ITEM_ID, true)
		rc_menu.set_item_disabled(MOVE_UP_ID, true)
		rc_menu.set_item_disabled(MOVE_DOWN_ID, true)
		rc_menu.set_item_disabled(RENAME_ITEM_ID, true)
		rc_menu.set_item_disabled(DELETE_ITEM_ID, true)

func show_rc_menu(at: Vector2):
	rc_menu.position = at
	rc_menu.popup()
	print("ppop")

func new_list_item(at: int, name: String = "New item %s" % event_list.item_count) -> int:

	var idx := event_list.add_item(name)

	return idx

func _on_popup_menu_id_pressed(id: int) -> void:
	var item_id := event_list.get_item_at_position(rc_menu.position) # TODO: selected item

	match id:
		NEW_ITEM_ID:
			print("new item")
			var idx := new_list_item(item_id)
			event_list.move_item(idx, item_id)

			emit_signal("new_item", item_id)
		DUPLICATE_ITEM_ID:
			print("duplicate item")
			event_list.duplicate(item_id)

			emit_signal("duplicate_item", item_id)
		MOVE_UP_ID:
			print("move up")
			event_list.move_item(item_id, item_id - 1)

			emit_signal("move_up", item_id)
		MOVE_DOWN_ID:
			print("move down")
			event_list.move_item(item_id, item_id + 1)

			emit_signal("move_down", item_id)
		RENAME_ITEM_ID:
			print("rename item")

			rename_dialog.title = "Rename %s..." % event_list.get_item_text(item_id)

			rename_dialog.popup()
			rename_dialog.confirmed.connect(func():
				event_list.set_item_text(item_id, rename_dialog.text)
			, CONNECT_ONE_SHOT)
		DELETE_ITEM_ID:
			print("delete item")
			event_list.remove_item(item_id)
			
			emit_signal("delete_item", item_id)
#endregion
#region Hooks
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	event_list.item_activated.connect(_on_item_activated)
	event_list.item_clicked.connect(_on_item_clicked)
	event_list.empty_clicked.connect(_on_empty_clicked)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_text_delete"):
		while true:
			var items := event_list.get_selected_items()
			if items.size() > 0:
				event_list.remove_item(items[0])
			else:
				break
#endregion

func _on_item_activated(index: int) -> void:
	pass

func _on_item_clicked(index: int, at: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		create_list_item_popup_options(index)
		show_rc_menu(at)

func _on_empty_clicked(at: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		create_list_item_popup_options()
		show_rc_menu(at)

func _on_add_button_pressed() -> void:
	var idx := new_list_item(event_list.item_count)
