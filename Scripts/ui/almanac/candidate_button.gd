class_name CandidateButton
extends Button

signal state_changed

enum SelectState { NONE, SELECTED, RULED_OUT }

var candidate: Resource  
var state: SelectState = SelectState.NONE
var is_filtered_out: bool = false

## Customize these two colors however
@export var normal_color: Color = Color.BLACK
@export var filtered_out_color: Color = Color(0.063, 0.055, 0.004, 0.102)


func _ready() -> void:
	pressed.connect(_on_pressed)
	_update_visual()


func _on_pressed() -> void:
	match state:
		SelectState.NONE:
			state = SelectState.SELECTED
		SelectState.SELECTED:
			state = SelectState.RULED_OUT
		SelectState.RULED_OUT:
			state = SelectState.NONE
	_update_visual()
	state_changed.emit()


func set_filtered_out(value: bool) -> void:
	is_filtered_out = value
	_update_visual()


func _update_visual() -> void:
	var base_text: String = candidate.display_name if candidate else ""
	match state:
		SelectState.NONE:
			text = base_text
		SelectState.SELECTED:
			text = base_text + "  ○"
		SelectState.RULED_OUT:
			text = base_text + "  ✕"
	add_theme_color_override("font_color", filtered_out_color if is_filtered_out else normal_color)
