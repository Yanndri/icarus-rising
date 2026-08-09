extends Control

enum PageMode { BEHAVIOR, SKY }

@export var page_mode: PageMode = PageMode.BEHAVIOR
@export var clue_ids: Array[String] = []
@export var clue_names: Array[String] = []

@onready var _clue_list: VBoxContainer = %ClueList
@onready var _candidate_list: VBoxContainer = %CandidateList


func _ready() -> void:
	if clue_ids.is_empty():
		_use_default_clue_pool()
	_build_clue_checkboxes()
	_refresh_candidates()
	GameState.clue_discovered.connect(_on_clue_discovered)


func _use_default_clue_pool() -> void:
	if page_mode == PageMode.BEHAVIOR:
		clue_ids = ClueDefinitions.BEHAVIOR_CLUE_IDS + ClueDefinitions.BIRTH_CLUE_IDS
		clue_names = ClueDefinitions.BEHAVIOR_CLUE_NAMES + ClueDefinitions.BIRTH_CLUE_NAMES
	else:
		clue_ids = ClueDefinitions.SKY_CLUE_IDS
		clue_names = ClueDefinitions.SKY_CLUE_NAMES


func _build_clue_checkboxes() -> void:
	for child in _clue_list.get_children():
		child.queue_free()
	for i in clue_ids.size():
		var checkbox := CheckBox.new()
		checkbox.text = clue_names[i]
		checkbox.toggled.connect(_on_clue_checkbox_toggled.bind(clue_ids[i]))
		_clue_list.add_child(checkbox)


func _on_clue_checkbox_toggled(is_checked: bool, clue_id: String) -> void:
	if not is_checked:
		return
	if page_mode == PageMode.BEHAVIOR:
		GameState.discover_behavior_clue(clue_id)
	else:
		GameState.discover_sky_clue(clue_id)


func _on_clue_discovered(_clue_id: String) -> void:
	_refresh_candidates()


func _refresh_candidates() -> void:
	for child in _candidate_list.get_children():
		child.queue_free()
	var candidates: Array = (
		GameState.get_candidate_alignments() if page_mode == PageMode.BEHAVIOR
		else GameState.get_candidate_events()
	)
	for candidate in candidates:
		var label := Label.new()
		label.text = candidate.display_name
		var is_locked: bool = (
			candidate == GameState.current_alignment if page_mode == PageMode.BEHAVIOR
			else candidate == GameState.current_event
		)
		if is_locked:
			label.text += "  \u2713 LOCKED"
			label.add_theme_color_override("font_color", Color.LIME_GREEN)
		_candidate_list.add_child(label)
	if candidates.is_empty():
		var none_label := Label.new()
		none_label.text = "(no matches yet)"
		none_label.modulate = Color(1, 1, 1, 0.5)
		_candidate_list.add_child(none_label)
