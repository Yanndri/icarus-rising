extends Node
## Global cursor controller shared by every scene.

const DEFAULT_HAND := preload("res://Assets/defaultHand.png")
const CLICKING_HAND := preload("res://Assets/clickingHand.png")
const CURSOR_HOTSPOT := Vector2(8, 8)


func _ready() -> void:
	set_default()


func set_default() -> void:
	_set_cursor(DEFAULT_HAND)


func set_clicking() -> void:
	_set_cursor(CLICKING_HAND)


func _set_cursor(cursor_texture: Texture2D) -> void:
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, CURSOR_HOTSPOT)
