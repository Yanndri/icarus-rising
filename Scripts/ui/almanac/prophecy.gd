extends Control

@onready var _prophecy_label: Label = %ProphecyLabel


func _ready() -> void:
	var alignment := GameState.get_selected_alignment()
	var sky_event := GameState.get_selected_event()
	_prophecy_label.text = "%s\n\n%s" % [alignment.description, sky_event.description]
