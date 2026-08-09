extends Node
#I was gonna comment and shit but I forgot
signal clue_state_changed(clue_id: String, is_behavior: bool)
signal alignment_locked(alignment: CosmicAlignment)
signal event_locked(sky_event: SkyEvent)
signal alignment_unlocked
signal event_unlocked

@export var alignments_directory := "res://Data/Alignments"
@export var events_directory := "res://Data/Events"

var all_alignments: Array[CosmicAlignment] = []
var all_events: Array[SkyEvent] = []

var selected_behavior_clues: Array[String] = []
var ruled_out_behavior_clues: Array[String] = []
var selected_sky_clues: Array[String] = []
var ruled_out_sky_clues: Array[String] = []

var current_alignment: CosmicAlignment = null
var current_event: SkyEvent = null


func _ready() -> void:
	all_alignments.assign(_load_resources_of_type(alignments_directory, CosmicAlignment))
	all_events.assign(_load_resources_of_type(events_directory, SkyEvent))
	print("GameState ready: %d alignments, %d events loaded." % [all_alignments.size(), all_events.size()])


## state should be a ClueButton.ClueState value (0=NONE, 1=SELECTED, 2=RULED_OUT)
func set_behavior_clue_state(clue_id: String, state: int) -> void:
	selected_behavior_clues.erase(clue_id)
	ruled_out_behavior_clues.erase(clue_id)
	if state == 1:
		selected_behavior_clues.append(clue_id)
	elif state == 2:
		ruled_out_behavior_clues.append(clue_id)
	clue_state_changed.emit(clue_id, true)
	_refresh_alignment_lock()


func set_sky_clue_state(clue_id: String, state: int) -> void:
	selected_sky_clues.erase(clue_id)
	ruled_out_sky_clues.erase(clue_id)
	if state == 1:
		selected_sky_clues.append(clue_id)
	elif state == 2:
		ruled_out_sky_clues.append(clue_id)
	clue_state_changed.emit(clue_id, false)
	_refresh_event_lock()


func start_new_visitor() -> void:
	selected_behavior_clues.clear()
	ruled_out_behavior_clues.clear()
	selected_sky_clues.clear()
	ruled_out_sky_clues.clear()
	current_alignment = null
	current_event = null


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


func _refresh_alignment_lock() -> void:
	var candidates := get_candidate_alignments()
	if candidates.size() == 1 and candidates[0].matches(selected_behavior_clues):
		if current_alignment != candidates[0]:
			current_alignment = candidates[0]
			alignment_locked.emit(current_alignment)
	elif current_alignment != null:
		current_alignment = null
		alignment_unlocked.emit()


func _refresh_event_lock() -> void:
	var candidates := get_candidate_events()
	if candidates.size() == 1 and candidates[0].matches(selected_sky_clues):
		if current_event != candidates[0]:
			current_event = candidates[0]
			event_locked.emit(current_event)
	elif current_event != null:
		current_event = null
		event_unlocked.emit()


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
