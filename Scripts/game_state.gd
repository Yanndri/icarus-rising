extends Node

signal clue_state_changed(clue_id: String, is_behavior: bool)
signal alignment_selection_changed
signal event_selection_changed
signal diagnosis_submitted(alignment: CosmicAlignment, sky_event: SkyEvent)

@export var alignments_directory := "res://Data/Alignments"
@export var events_directory := "res://Data/Events"

var all_alignments: Array[CosmicAlignment] = []
var all_events: Array[SkyEvent] = []

var selected_behavior_clues: Array[String] = []
var ruled_out_behavior_clues: Array[String] = []
var selected_sky_clues: Array[String] = []
var ruled_out_sky_clues: Array[String] = []

var selected_alignments: Array[CosmicAlignment] = []
var ruled_out_alignments: Array[CosmicAlignment] = []
var selected_events: Array[SkyEvent] = []
var ruled_out_events: Array[SkyEvent] = []


func _ready() -> void:
	all_alignments.assign(_load_resources_of_type(alignments_directory, CosmicAlignment))
	all_events.assign(_load_resources_of_type(events_directory, SkyEvent))
	print("GameState ready: %d alignments, %d events loaded." % [all_alignments.size(), all_events.size()])


func set_behavior_clue_state(clue_id: String, state: int) -> void:
	selected_behavior_clues.erase(clue_id)
	ruled_out_behavior_clues.erase(clue_id)
	if state == 1:
		selected_behavior_clues.append(clue_id)
	elif state == 2:
		ruled_out_behavior_clues.append(clue_id)
	clue_state_changed.emit(clue_id, true)


func set_sky_clue_state(clue_id: String, state: int) -> void:
	selected_sky_clues.erase(clue_id)
	ruled_out_sky_clues.erase(clue_id)
	if state == 1:
		selected_sky_clues.append(clue_id)
	elif state == 2:
		ruled_out_sky_clues.append(clue_id)
	clue_state_changed.emit(clue_id, false)


func set_alignment_state(alignment: CosmicAlignment, state: int) -> void:
	selected_alignments.erase(alignment)
	ruled_out_alignments.erase(alignment)
	if state == 1:
		selected_alignments.append(alignment)
	elif state == 2:
		ruled_out_alignments.append(alignment)
	alignment_selection_changed.emit()


func set_event_state(sky_event: SkyEvent, state: int) -> void:
	selected_events.erase(sky_event)
	ruled_out_events.erase(sky_event)
	if state == 1:
		selected_events.append(sky_event)
	elif state == 2:
		ruled_out_events.append(sky_event)
	event_selection_changed.emit()


func can_submit() -> bool:
	return selected_alignments.size() == 1 and selected_events.size() == 1


func get_selected_alignment() -> CosmicAlignment:
	return selected_alignments[0] if selected_alignments.size() == 1 else null


func get_selected_event() -> SkyEvent:
	return selected_events[0] if selected_events.size() == 1 else null


func submit_diagnosis() -> void:
	if can_submit():
		diagnosis_submitted.emit(get_selected_alignment(), get_selected_event())


func start_new_visitor() -> void:
	selected_behavior_clues.clear()
	ruled_out_behavior_clues.clear()
	selected_sky_clues.clear()
	ruled_out_sky_clues.clear()
	selected_alignments.clear()
	ruled_out_alignments.clear()
	selected_events.clear()
	ruled_out_events.clear()


func get_candidate_alignments() -> Array[CosmicAlignment]:
	var candidates: Array[CosmicAlignment] = []
	for alignment in all_alignments:
		if _is_candidate(selected_behavior_clues, ruled_out_behavior_clues, alignment.required_clues):
			candidates.append(alignment)
	return candidates


func get_candidate_events() -> Array[SkyEvent]:
	var candidates: Array[SkyEvent] = []
	for sky_event in all_events:
		if _is_candidate(selected_sky_clues, ruled_out_sky_clues, sky_event.required_clues):
			candidates.append(sky_event)
	return candidates


func _is_candidate(selected_clues: Array[String], ruled_out_clues: Array[String], required_clues: Array[String]) -> bool:
	for clue in selected_clues:
		if clue not in required_clues:
			return false
	for clue in ruled_out_clues:
		if clue in required_clues:
			return false
	return true


func _load_resources_of_type(directory_path: String, expected_type: Script) -> Array:
	var results: Array = []
	var directory := DirAccess.open(directory_path)
	if directory == null:
		push_warning("GameState could not open directory: %s" % directory_path)
		return results
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while file_name != "":
		if not directory.current_is_dir() and file_name.get_extension() == "tres":
			var resource := load(directory_path.path_join(file_name))
			if is_instance_of(resource, expected_type):
				results.append(resource)
		file_name = directory.get_next()
	directory.list_dir_end()
	return results
