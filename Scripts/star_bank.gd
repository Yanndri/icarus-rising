extends Node
## Global star currency(gambling) tracker.
## this language is weird coming from a c++ standpoint

signal stars_changed(total: int)

const SAVE_PATH := "user://star_bank.cfg"

@export var persist_between_sessions := true # if on the stars amount persist through sessions.

var total_stars: int = 0:
	set(value):
		total_stars = value
		stars_changed.emit(total_stars)

func _ready() -> void:
	_load()
	stars_changed.connect(func(total): print("Stars: ", total))

func add_stars(amount: int = 1) -> void:
	total_stars += amount
	_save()

func spend_stars(amount: int) -> bool:
	if amount > total_stars:
		return false
	total_stars -= amount
	_save()
	return true

func _save() -> void:
	if not persist_between_sessions:
		return
	var config := ConfigFile.new()
	config.set_value("bank", "total_stars", total_stars)
	config.save(SAVE_PATH)

func _load() -> void:
	if not persist_between_sessions:
		total_stars = 0
		return
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		total_stars = config.get_value("bank", "total_stars", 0)
		
func clear_stars() -> void:
	total_stars = 0
	_save()
