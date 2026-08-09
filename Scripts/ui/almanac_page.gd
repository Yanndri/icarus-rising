extends Control
# same here, I dont really like commenting when Im in the flow~~~
enum PageMode { BEHAVIOR, SKY }

@export var page_mode: PageMode = PageMode.BEHAVIOR
@export var clue_ids: Array[String] = []
@export var clue_names: Array[String] = []
@export var clue_descriptions: Array[String] = []

@onready var _clue_list: Container = %ClueList
@onready var _candidate_list: Container = %CandidateList
@onready var _description_label: Label = %DescriptionLabel


func _ready() -> void:
	if clue_ids.is_empty():
		_use_default_clue_pool()
	_build_clue_buttons()
	_refresh_candidates()
	GameState.clue_state_changed.connect(_on_clue_state_changed)


func _use_default_clue_pool() -> void:
	if page_mode == PageMode.BEHAVIOR:
		clue_ids = ClueDefinitions.BEHAVIOR_CLUE_IDS + ClueDefinitions.BIRTH_CLUE_IDS
		clue_names = ClueDefinitions.BEHAVIOR_CLUE_NAMES + ClueDefinitions.BIRTH_CLUE_NAMES
	else:
		clue_ids = ClueDefinitions.SKY_CLUE_IDS
		clue_names = ClueDefinitions.SKY_CLUE_NAMES


func _build_clue_buttons() -> void:
	for child in _clue_list.get_children():
		child.queue_free()
	for i in clue_ids.size():
		var button := ClueButton.new()
		button.clue_id = clue_ids[i]
		button.base_text = clue_names[i]
		button.description = clue_descriptions[i] if i < clue_descriptions.size() else clue_names[i]
		button.hovered.connect(func(desc): _description_label.text = desc)
		button.unhovered.connect(func(): _description_label.text = "")
		button.state_changed.connect(_on_clue_button_state_changed.bind(button))
		_clue_list.add_child(button)


func _on_clue_button_state_changed(button: ClueButton) -> void:
	if page_mode == PageMode.BEHAVIOR:
		GameState.set_behavior_clue_state(button.clue_id, button.state)
	else:
		GameState.set_sky_clue_state(button.clue_id, button.state)


func _on_clue_state_changed(_clue_id: String, is_behavior: bool) -> void:
	if is_behavior == (page_mode == PageMode.BEHAVIOR):
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
			label.text += "  ✓ LOCKED"
			label.add_theme_color_override("font_color", Color.LIME_GREEN)
		_candidate_list.add_child(label)
	if candidates.is_empty():
		var none_label := Label.new()
		none_label.text = "(no matches yet)"
		none_label.modulate = Color(1, 1, 1, 0.5)
		_candidate_list.add_child(none_label)
