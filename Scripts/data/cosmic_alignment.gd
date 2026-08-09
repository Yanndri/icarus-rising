class_name CosmicAlignment
extends Resource

@export var display_name: String = ""
@export_multiline var description: String = ""
@export var required_clues: Array[String] = []

func matches(discovered_clues: Array[String]) -> bool:
	for clue in required_clues:
		if clue not in discovered_clues:
			return false
	return true
