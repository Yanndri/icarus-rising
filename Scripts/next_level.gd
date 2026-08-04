extends Control

const NEXT_LEVEL_SCENE_PATH := "res://main.tscn"

func _on_next_level_button_pressed() -> void:
	var error := get_tree().change_scene_to_file(NEXT_LEVEL_SCENE_PATH)
	if error != OK:
		push_error("Could not load next level: %s" % NEXT_LEVEL_SCENE_PATH)
