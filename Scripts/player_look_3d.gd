extends Node3D
## Hold the right mouse button and drag to look around.

@export var look_sensitivity := 0.003
@export var min_pitch := -180.0
@export var max_pitch := 180.0

@onready var camera: Camera3D = $Camera3D

var _is_looking := false
var _yaw := 0.0
var _pitch := 0.0


func _ready() -> void:
	_yaw = camera.rotation.y
	_pitch = camera.rotation.x
	camera.current = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		_is_looking = event.pressed
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _is_looking else Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and _is_looking:
		_yaw -= event.relative.x * look_sensitivity
		_pitch = clampf(
			_pitch - event.relative.y * look_sensitivity,
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch)
		)
		camera.rotation.y = _yaw
		camera.rotation.x = _pitch
		get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	if _is_looking:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
