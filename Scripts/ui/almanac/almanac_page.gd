extends Control

enum PageMode { BEHAVIOR, SKY }

@export var page_mode: PageMode = PageMode.BEHAVIOR
@export var clue_ids: Array[String] = []
@export var clue_names: Array[String] = []
@export var clue_descriptions: Array[String] = []
@export var clue_images: Array[Texture2D] = []

@onready var _clue_list: Container = %ClueList
@onready var _candidate_list: Container = %CandidateList
@onready var _description_label: Label = %DescriptionLabel
@onready var _description_image: TextureRect = %DescriptionImage


func _ready() -> void:
	if clue_ids.is_empty():
		_use_default_clue_pool()
	_build_clue_buttons()
	_build_candidate_buttons()
	GameState.clue_state_changed.connect(_on_clue_state_changed)


func _use_default_clue_pool() -> void:
	if page_mode == PageMode.BEHAVIOR:
		clue_ids = ClueDefinitions.BEHAVIOR_CLUE_IDS + ClueDefinitions.BIRTH_CLUE_IDS
		clue_names = ClueDefinitions.BEHAVIOR_CLUE_NAMES + ClueDefinitions.BIRTH_CLUE_NAMES
		clue_descriptions = ClueDefinitions.BEHAVIOR_CLUE_DESCRIPTIONS + ClueDefinitions.BIRTH_CLUE_DESCRIPTIONS
	else:
		clue_ids = ClueDefinitions.SKY_CLUE_IDS
		clue_names = ClueDefinitions.SKY_CLUE_NAMES
		clue_descriptions = ClueDefinitions.SKY_CLUE_DESCRIPTIONS


func _build_clue_buttons() -> void:
	for child in _clue_list.get_children():
		child.queue_free()
	for i in clue_ids.size():
		var button := ClueButton.new()
		button.clue_id = clue_ids[i]
		button.base_text = clue_names[i]
		button.description = clue_descriptions[i] if i < clue_descriptions.size() else clue_names[i]
		var clue_index := i
		button.hovered.connect(func(desc):
			_description_label.text = desc
			_description_image.texture = clue_images[clue_index] if clue_index < clue_images.size() else null
		)
		button.unhovered.connect(func():
			_description_label.text = ""
			_description_image.texture = null
		)
		button.state_changed.connect(_on_clue_button_state_changed.bind(button))
		_clue_list.add_child(button)


func _on_clue_button_state_changed(button: ClueButton) -> void:
	if page_mode == PageMode.BEHAVIOR:
		GameState.set_behavior_clue_state(button.clue_id, button.state)
	else:
		GameState.set_sky_clue_state(button.clue_id, button.state)


func _build_candidate_buttons() -> void:
	for child in _candidate_list.get_children():
		child.queue_free()
	var source: Array = GameState.all_alignments if page_mode == PageMode.BEHAVIOR else GameState.all_events
	for item in source:
		var button := CandidateButton.new()
		button.candidate = item
		button.state_changed.connect(_on_candidate_button_state_changed.bind(button))
		_candidate_list.add_child(button)
	_refresh_candidate_styles()


func _on_candidate_button_state_changed(button: CandidateButton) -> void:
	if page_mode == PageMode.BEHAVIOR:
		GameState.set_alignment_state(button.candidate, button.state)
	else:
		GameState.set_event_state(button.candidate, button.state)


func _on_clue_state_changed(_clue_id: String, is_behavior: bool) -> void:
	if is_behavior == (page_mode == PageMode.BEHAVIOR):
		_refresh_candidate_styles()


func _refresh_candidate_styles() -> void:
	var candidates: Array = (
		GameState.get_candidate_alignments() if page_mode == PageMode.BEHAVIOR
		else GameState.get_candidate_events()
	)
	for button in _candidate_list.get_children():
		if button is CandidateButton:
			button.set_filtered_out(button.candidate not in candidates)
