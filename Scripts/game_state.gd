extends Node

signal clue_discovered(clue_id: String)
signal alignment_locked(alignment: CosmicAlignment)
signal event_locked(sky_event: SkyEvent)

@export var alignments_directory := "res://Data/Alignments"
@export var events_directory := "res://Data/Events"

var all_alignments: Array[CosmicAlignment] = []
var all_events: Array[SkyEvent] = []
var discovered_behavior_clues: Array[String] = []
var discovered_sky_clues: Array[String] = []
var current_alignment: CosmicAlignment = null
var current_event: SkyEvent = null


func _ready() -> void:
	all_alignments.assign(_load_resources_of_type(alignments_directory, CosmicAlignment))
	all_events.assign(_load_resources_of_type(events_directory, SkyEvent))
	print("GameState ready: %d alignments, %d events loaded." % [all_alignments.size(), all_events.size()])


func discover_behavior_clue(clue_id: String) -> void:
	if clue_id in discovered_behavior_clues:
		return
	discovered_behavior_clues.append(clue_id)
	clue_discovered.emit(clue_id)
	_try_lock_alignment()


func discover_sky_clue(clue_id: String) -> void:
	if clue_id in discovered_sky_clues:
		return
	discovered_sky_clues.append(clue_id)
	clue_discovered.emit(clue_id)
	_try_lock_event()


func start_new_visitor() -> void:
	discovered_behavior_clues.clear()
	discovered_sky_clues.clear()
	current_alignment = null
	current_event = null


func get_candidate_alignments() -> Array[CosmicAlignment]:
	var candidates: Array[CosmicAlignment] = []
	for alignment in all_alignments:
		if _is_candidate(discovered_behavior_clues, alignment.required_clues):
			candidates.append(alignment)
	return candidates


func get_candidate_events() -> Array[SkyEvent]:
	var candidates: Array[SkyEvent] = []
	for sky_event in all_events:
		if _is_candidate(discovered_sky_clues, sky_event.required_clues):
			candidates.append(sky_event)
	return candidates


func _is_candidate(checked_clues: Array[String], required_clues: Array[String]) -> bool:
	for clue in checked_clues:
		if clue not in required_clues:
			return false
	return true


func _try_lock_alignment() -> void:
	if current_alignment != null:
		return
	for alignment in all_alignments:
		if alignment.matches(discovered_behavior_clues):
			current_alignment = alignment
			alignment_locked.emit(alignment)
			return


func _try_lock_event() -> void:
	if current_event != null:
		return
	for sky_event in all_events:
		if sky_event.matches(discovered_sky_clues):
			current_event = sky_event
			event_locked.emit(sky_event)
			return


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
