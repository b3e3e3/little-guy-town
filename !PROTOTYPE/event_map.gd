extends Resource
class_name EventMap

# TODO: refactor to c++
class EventInfo:
	var position: Vector2

	func _init(pos: Vector2) -> void:
		position = pos

# TODO: refactor to c++
class EventConnection:
	var from_event: Event
	var to_event: Event
	var from_port: int
	var to_port: int

var connections: Array[EventConnection]
@export var events: Dictionary = {}
@export var metadata: Dictionary = {
    "version": "1.0.0",
    "created_at": 0,
    "last_modified": 0
}

func add_event(event: Event, info: EventInfo):
	events[event] = info

func save_map(path: String) -> Error:
	metadata["last_modified"] = Time.get_unix_time_from_system()
	return ResourceSaver.save(self, path)

static func load_map(path: String) -> EventMap:
	return load(path) as EventMap

# C++ TODO: create event? maybe we dont have to since we have add_event?

func connect_events(from: Event, to: Event, from_port: int, to_port: int) -> EventConnection:
	var connection = EventConnection.new()

	connection.from_event = from
	connection.to_event = to
	connection.from_port = from_port
	connection.to_port = to_port

	connections.append(connection)
	return connection