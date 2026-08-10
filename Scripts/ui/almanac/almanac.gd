extends Control

@export var prophecy_scene_path := "res://Scenes/almanac/prophecy.tscn"

@onready var _status_label: Label = %SelectionStatusLabel

@onready var _submit_button: BaseButton = %SubmitButton
@onready var _confirmation_overlay: Control = %ConfirmationOverlay
@onready var _confirmation_label: Label = %ConfirmationLabel
@onready var _check_button: BaseButton = %CheckButton
@onready var _x_button: BaseButton = %XButton

var _status_fade_tween: Tween

func _ready() -> void:
	_confirmation_overlay.visible = false
	_submit_button.pressed.connect(_on_submit_pressed)
	_check_button.pressed.connect(_on_check_pressed)
	_x_button.pressed.connect(_on_x_pressed)
	GameState.alignment_selection_changed.connect(_refresh_submit_button)
	GameState.event_selection_changed.connect(_refresh_submit_button)
	_refresh_submit_button()

func _refresh_status_label() -> void:
	var messages: Array[String] = []

	var alignment_count := GameState.selected_alignments.size()
	if alignment_count == 0:
		messages.append("⊛ Alignment not selected")
	elif alignment_count > 1:
		messages.append("⊛ More than 1 Alignment selected")

	var event_count := GameState.selected_events.size()
	if event_count == 0:
		messages.append("⊛ Event not selected")
	elif event_count > 1:
		messages.append("⊛ More than 1 Event selected")

	_status_label.text = "\n".join(messages)
	_status_label.modulate.a = 1.0

	if _status_fade_tween:
		_status_fade_tween.kill()

	if not messages.is_empty():
		_status_fade_tween = create_tween()
		_status_fade_tween.tween_interval(0.3)
		_status_fade_tween.tween_property(_status_label, "modulate:a", 0.0, 0.5)

	_status_label.text = "\n".join(messages)
	 
func _refresh_submit_button() -> void:
	pass  # button stays clickable regardles
	
func _on_submit_pressed() -> void:
	if not GameState.can_submit():
		_refresh_status_label()
		return
	var alignment := GameState.get_selected_alignment()
	var sky_event := GameState.get_selected_event()
	_confirmation_label.text = "Alignment: %s\n\nCosmic Event: %s" % [
		alignment.display_name, sky_event.display_name
	]
	_confirmation_overlay.visible = true

func _on_x_pressed() -> void:
	_confirmation_overlay.visible = false


func _on_check_pressed() -> void:
	GameState.submit_diagnosis()
	get_tree().change_scene_to_file(prophecy_scene_path)
