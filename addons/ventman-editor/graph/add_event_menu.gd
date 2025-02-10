extends PopupMenu

var event_types: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready():
	var class_list := ClassDB.get_class_list()

	print("Getting event types...")
	var i := 0
	
	for name in class_list:
		if ClassDB.is_parent_class(name, "Event"):
			if name == "Event":
				# TODO: DO THIS IN C++
				continue
			print("Found %s (%s)" % [name, i])
			add_item(name, i)
			i += 1
			event_types.push_back(name)

func instantiate_event(id: int) -> Event:
	if ClassDB.can_instantiate(event_types[id]):
		return ClassDB.instantiate(event_types[id])
	else:
		printerr("Cannot instantiate event type %s" % event_types[id])
		return null
