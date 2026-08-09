class_name ClueButton
extends Button

signal hovered(description: String)
signal unhovered
signal state_changed

enum ClueState { NONE, SELECTED, RULED_OUT }

var clue_id: String = ""
var base_text: String = ""
var description: String = ""
var state: ClueState = ClueState.NONE


func _ready() -> void:
	toggle_mode = false
	pressed.connect(_on_pressed)
	mouse_entered.connect(func(): hovered.emit(description))
	mouse_exited.connect(func(): unhovered.emit())
	_update_visual()


func _on_pressed() -> void:
	match state:
		ClueState.NONE:
			state = ClueState.SELECTED
		ClueState.SELECTED:
			state = ClueState.RULED_OUT
		ClueState.RULED_OUT:
			state = ClueState.NONE
	_update_visual()
	state_changed.emit()


func _update_visual() -> void:
	# Placeholder markers
	# If have those textures, replace the "text = ..." lines below
	# "icon = preload("res://Assets/UI/circle.png")" 
	
	match state:
		ClueState.NONE:
			text = base_text
		ClueState.SELECTED:
			text = base_text + "  ○"
		ClueState.RULED_OUT:
			text = base_text + "  ✕"
